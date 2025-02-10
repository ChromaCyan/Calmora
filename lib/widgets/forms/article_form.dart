import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:armstrong/services/api.dart';
import 'package:armstrong/services/supabase.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ArticleFormScreen extends StatefulWidget {
  final Map<String, dynamic>? article; // Null if adding a new article
  final String specialistId;

  const ArticleFormScreen({
    Key? key,
    this.article,
    required this.specialistId,
  }) : super(key: key);

  @override
  _ArticleFormScreenState createState() => _ArticleFormScreenState();
}

class _ArticleFormScreenState extends State<ArticleFormScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final ApiRepository _apiRepository = ApiRepository();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    if (widget.article != null) {
      _titleController.text = widget.article!["title"];
      _contentController.text = widget.article!["content"];
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitArticle() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    String? heroImageUrl = widget.article?["heroImage"];
    if (_image != null) {
      heroImageUrl = await SupabaseService.uploadArticleImage(_image!);
      if (heroImageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image')),
        );
        return;
      }
    }

    try {
      if (widget.article == null) {
        await _apiRepository.createArticle(
          title: _titleController.text,
          content: _contentController.text,
          heroImage: heroImageUrl ?? '',
          specialistId: widget.specialistId,
        );
      } else {
        await _apiRepository.updateArticle(
          articleId: widget.article!["_id"],
          title: _titleController.text,
          content: _contentController.text,
          heroImage: heroImageUrl,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.article == null ? 'Article added!' : 'Article updated!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.article == null ? 'Add Article' : 'Edit Article')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 5,
            ),
            const SizedBox(height: 10),
            _image == null && widget.article?['heroImage'] != null
                ? Image.network(widget.article!['heroImage'], height: 150)
                : (_image != null ? Image.file(_image!, height: 150) : const Text('No image selected')),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _submitArticle,
              child: Text(widget.article == null ? 'Submit Article' : 'Update Article'),
            ),
          ],
        ),
      ),
    );
  }
}
