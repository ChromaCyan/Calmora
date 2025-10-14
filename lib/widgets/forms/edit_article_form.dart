import 'dart:io';
import 'package:armstrong/models/article/article.dart';
import 'package:armstrong/services/supabase.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/universal/blocs/articles/article_bloc.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:armstrong/widgets/navigation/appbar.dart';
import 'package:armstrong/widgets/forms/edit_article_contentfield.dart';
import 'dart:ui';

class EditArticleForm extends StatefulWidget {
  final Article article;

  const EditArticleForm({Key? key, required this.article}) : super(key: key);

  @override
  _EditArticleFormState createState() => _EditArticleFormState();
}

class _EditArticleFormState extends State<EditArticleForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  List<String> _categories = [
    'Health',
    'Social',
    'Relationships',
    'Growth',
    'Coping Strategies',
    'Mental Wellness',
    'Self-Care'
  ];
  List<String> _selectedCategories = [];

  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _initializeFormData();
  }

  void _initializeFormData() {
    _titleController.text = widget.article.title;
    _contentController.text = widget.article.content;
    _selectedCategories = widget.article.categories
        .map((category) =>
            category[0].toUpperCase() + category.substring(1).toLowerCase())
        .toList();
    _selectedGender = widget.article.targetGender;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _showSnackBar(String title, String message, ContentType type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: title,
          message: message,
          contentType: type,
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<String?> _uploadImageToSupabase(File image) async {
    return await SupabaseService.uploadArticleImage(image);
  }

  Future<void> _submitEditedArticle() async {
    if (_titleController.text.isEmpty ||
        _contentController.text.isEmpty ||
        _selectedCategories.isEmpty) {
      _showSnackBar(
        "Warning",
        "Please fill all fields and choose 1-2 categories..",
        ContentType.warning,
      );
      return;
    }

    if (_selectedCategories.length > 2) {
      _showSnackBar(
        "Categories select error!",
        'You can only select up to 2 categories',
        ContentType.warning,
      );
      return;
    }

    String? heroImageUrl = widget.article.heroImage;
    if (_image != null) {
      heroImageUrl = await _uploadImageToSupabase(_image!);
      if (heroImageUrl == null) {
        _showSnackBar(
          "Failed to upload image",
          "Failed to upload image, please check your internet connection and try again..",
          ContentType.failure,
        );
        return;
      }
    }

    context.read<ArticleBloc>().add(
          UpdateArticle(
            articleId: widget.article.id,
            title: _titleController.text,
            content: _contentController.text,
            heroImage: heroImageUrl ?? widget.article.heroImage,
            categories:_selectedCategories.map((c) => c.toLowerCase()).toList(),
            targetGender: (_selectedGender ?? 'everyone').toLowerCase().trim(),
          ),
        );
    _showSnackBar(
      "Success",
      "Article updated successfully!",
      ContentType.success,
    );
    Navigator.pop(context, true);
  }

//<<<=== New Build Method ===>>>
Future<void> _openContentEditor() async {
  final updatedContent = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditArticleContentFieldPage(
        initialContent: _contentController.text,
      ),
    ),
  );

  if (updatedContent != null && updatedContent is String) {
    setState(() {
      _contentController.text = updatedContent;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
            child: Container(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          onPressed: () async {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Edit your article",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "images/login_bg_image.png",
            fit: BoxFit.fill,
          ),
          Container(
            color: theme.colorScheme.surface.withOpacity(0.6),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: const SizedBox.expand(),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // const Text(
                      //       'Edit Article',
                      //       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      //     ),
                      const SizedBox(height: 40),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            // The image container
                            Container(
                              height: 250,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                                image: _image != null
                                    ? DecorationImage(
                                        image: FileImage(_image!),
                                        fit: BoxFit.cover,
                                      )
                                    : DecorationImage(
                                        image: NetworkImage(widget.article.heroImage),
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),

                            // ✅ Moved Positioned outside the Container (so it works properly)
                            if (_image != null)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _image = null;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.background.withOpacity(0.7),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: Theme.of(context).colorScheme.onBackground,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                          const SizedBox(height: 16),
                          // TextFormField(
                          //   controller: _titleController,
                          //   decoration: InputDecoration(
                          //     labelText: 'Title',
                          //     prefixIcon: const Icon(Icons.title),
                          //     filled: true,
                          //     fillColor: theme.colorScheme.surface,
                          //     border: OutlineInputBorder(
                          //       borderRadius: BorderRadius.circular(12),
                          //     ),
                          //   ),
                          // ),
                          TextFormField(
                            controller: _titleController,
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Title',
                              labelStyle: TextStyle(
                                color: Theme.of(context).hintColor,
                                fontSize: 14,
                              ),
                              hintText: 'Enter article title',
                              hintStyle: TextStyle(
                                color: Theme.of(context).hintColor,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.title,
                                color: Theme.of(context).iconTheme.color,
                              ),
                              filled: true,
                              fillColor: Theme.of(context)
                                  .colorScheme
                                  .surface
                                  .withOpacity(0.6), // match first field design
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(
                                  color: Theme.of(context).dividerColor,
                                  width: 1,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // TextFormField(
                          //   controller: _contentController,
                          //   maxLines: 5,
                          //   decoration: InputDecoration(
                          //     labelText: 'Content',
                          //     prefixIcon: const Icon(Icons.description),
                          //     filled: true,
                          //     fillColor: theme.colorScheme.surface,
                          //     border: OutlineInputBorder(
                          //       borderRadius: BorderRadius.circular(12),
                          //     ),
                          //   ),
                          // ),
                          GestureDetector(
                            onTap: _openContentEditor,
                            child: Container(
                              height: 250,
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(color: theme.dividerColor),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: SingleChildScrollView(
                                      physics: const AlwaysScrollableScrollPhysics(),
                                      child: Text(
                                        _contentController.text.isEmpty
                                            ? 'Edit your contents here...'
                                            : _contentController.text,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: _contentController.text.isEmpty
                                              ? theme.hintColor
                                              : theme.textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.chevron_right,
                                    color: theme.iconTheme.color?.withOpacity(0.6),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Divider(
                            thickness: 1.5,
                            color: Colors.grey,
                            indent: 40,
                            endIndent: 40,
                          ),

                          const SizedBox(height: 10),

                          Center(
                            child: Text(
                              'Categories',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onBackground,
                              ),
                            ),
                          ),
                          Column(
                            children: _categories.map((category) {
                              return CheckboxListTile(
                                title: Text(category),
                                value: _selectedCategories
                                    .map((c) => c.toLowerCase())
                                    .contains(category.toLowerCase()),
                                onChanged: (bool? selected) {
                                  setState(() {
                                    if (selected == true &&
                                        _selectedCategories.length < 2) {
                                      if (!_selectedCategories
                                          .map((c) => c.toLowerCase())
                                          .contains(category.toLowerCase())) {
                                        _selectedCategories.add(category);
                                      }
                                    } else {
                                      _selectedCategories.removeWhere(
                                          (c) => c.toLowerCase() == category.toLowerCase());
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          
                          const SizedBox(height: 20),

                          const Divider(
                            thickness: 1.5,
                            color: Colors.grey,
                            indent: 40,
                            endIndent: 40,
                          ),

                          SizedBox(height: 10),

                          Center(
                            child: Text(
                              'Target Gender',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onBackground,
                              ),
                            ),
                          ),
                          Column(
                            children: ['everyone', 'male', 'female'].map((gender) {
                              return RadioListTile<String>(
                                title: Text(
                                  gender[0].toUpperCase() + gender.substring(1),
                                ),
                                value: gender,
                                groupValue: _selectedGender,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedGender = value;
                                  });
                                },
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 16),

                          const Divider(
                            thickness: 1.5,
                            color: Colors.grey,
                            indent: 40,
                            endIndent: 40,
                          ),

                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _submitEditedArticle,
                                icon: Icon(
                                  Icons.save,
                                  size: 24,
                                ),
                                label: Text(
                                  "Save Changes",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 85, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  )
                                ),
                              ),
                            ],
                          ),
                          // SizedBox(
                          //   width: double.infinity,
                          //   child: ElevatedButton.icon(
                          //     onPressed: _submitEditedArticle,
                          //     icon: const Icon(Icons.save),
                          //     label: const Text('Save Changes'),
                          //     style: ElevatedButton.styleFrom(
                          //       backgroundColor: Colors.blue,
                          //       foregroundColor: Colors.white,
                          //     ),
                          //   ),
                          // ),
                          const SizedBox(height: 20),
                    ],
                  )
                ),
              ),
            ],
          ),
        ],
      )
    );
  }
}
