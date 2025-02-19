// profile_picture_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePictureWidget extends StatelessWidget {
  final File? selectedImage;
  final String? imageUrl;
  final VoidCallback onPickImage;

  const ProfilePictureWidget({
    Key? key,
    required this.selectedImage,
    required this.imageUrl,
    required this.onPickImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onPickImage,
        child: CircleAvatar(
          radius: 50,
          backgroundImage: selectedImage != null
              ? FileImage(selectedImage!)
              : (imageUrl != null
                  ? NetworkImage(imageUrl!)
                  : const AssetImage("assets/default-avatar.png"))
                      as ImageProvider,
        ),
      ),
    );
  }
}
