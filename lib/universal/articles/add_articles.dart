import 'package:armstrong/models/article/article.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:armstrong/services/api.dart';
import 'package:armstrong/services/supabase.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/widgets/navigation/appbar.dart';

class AddArticleScreen extends StatefulWidget {
  @override
  _AddArticleScreenState createState() => _AddArticleScreenState();
}

class _AddArticleScreenState extends State<AddArticleScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final ApiRepository _apiRepository = ApiRepository();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _userId;

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

  String? _selectedGender = 'everyone';

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final userId = await _storage.read(key: 'userId');
    setState(() {
      _userId = userId;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImageToSupabase(File image) async {
    return await SupabaseService.uploadArticleImage(image);
  }

  Future<void> _submitArticle() async {
    if (_titleController.text.isEmpty ||
        _contentController.text.isEmpty ||
        _image == null ||
        _selectedCategories.isEmpty) {
      _showSnackbar(
          'Please fill all fields, select an image, choose categories, and select target demographic',
          isError: true);
      return;
    }

    if (_selectedCategories.length > 2) {
      _showSnackbar('You can only select up to 2 categories', isError: true);
      return;
    }

    final normalizedCategories =
        _selectedCategories.map((category) => category.toLowerCase()).toList();

    final heroImageUrl = await _uploadImageToSupabase(_image!);
    if (heroImageUrl == null) {
      _showSnackbar('Failed to upload image', isError: true);
      return;
    }

    if (_userId == null) {
      await _loadUserId();
    }

    try {
      final response = await _apiRepository.createArticle(
        title: _titleController.text,
        content: _contentController.text,
        heroImage: heroImageUrl,
        specialistId: _userId ?? '',
        categories: normalizedCategories,
        targetGender: (_selectedGender ?? 'everyone').toLowerCase().trim(),
      );


      if (response.isNotEmpty) {
        _showSnackbar('Article would be reviewed by the Admin Team!');
        Navigator.pop(context);
      } else {
        _showSnackbar('Failed to add article', isError: true);
      }
    } catch (e) {
      _showSnackbar('Error: $e', isError: true);
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Publish Article"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Create an Article',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),

                // Image Picker with GestureDetector
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        height: 250,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          image: _image != null
                              ? DecorationImage(
                                  image: FileImage(_image!), fit: BoxFit.cover)
                              : null,
                        ),
                        child: _image == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image,
                                      size: 50,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant),
                                  SizedBox(height: 8),
                                  Text('Add image cover',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant)),
                                ],
                              )
                            : null,
                      ),

                      // Remove Button (only shown when an image is selected)
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
                                color: Theme.of(context)
                                    .colorScheme
                                    .background
                                    .withOpacity(0.7),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.close,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  size: 20),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Title TextField
                TextFormField(
                  controller: _titleController,
                  style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(
                        color: Theme.of(context).hintColor, fontSize: 14),
                    hintText: 'Enter article title',
                    hintStyle: TextStyle(
                        color: Theme.of(context).hintColor, fontSize: 14),
                    prefixIcon: Icon(Icons.title,
                        color: Theme.of(context).iconTheme.color),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: Theme.of(context).dividerColor, width: 1),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  ),
                ),
                SizedBox(height: 12),

                // Content TextField
                TextFormField(
                  controller: _contentController,
                  style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                  decoration: InputDecoration(
                    labelText: 'Content',
                    labelStyle: TextStyle(
                        color: Theme.of(context).hintColor, fontSize: 14),
                    hintText: 'Write your article content here...',
                    hintStyle: TextStyle(
                        color: Theme.of(context).hintColor, fontSize: 14),
                    prefixIcon: Icon(Icons.description,
                        color: Theme.of(context).iconTheme.color),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: Theme.of(context).dividerColor, width: 1),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  ),
                  maxLines: 5,
                ),
                SizedBox(height: 20),

                Center(
                  child: Text(
                    'Categories',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                ),

                // Category Dropdown
                Column(
                  children: _categories.map((category) {
                    return CheckboxListTile(
                      title: Text(category),
                      value: _selectedCategories.contains(category),
                      onChanged: (bool? selected) {
                        setState(() {
                          if (selected == true &&
                              _selectedCategories.length < 2) {
                            _selectedCategories.add(category);
                          } else {
                            _selectedCategories.remove(category);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                SizedBox(height: 20),

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

                SizedBox(height: 12),

                //Submit Button
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _submitArticle,
                        icon: Icon(Icons.send),
                        label: Text('Submit Article'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
