import 'dart:io';
import 'package:flutter/material.dart';

class ProfilePictureWidget extends StatelessWidget {
  final File? selectedImage;
  final String? imageUrl;
  final VoidCallback onPickImage;
  final bool isEditing;

  const ProfilePictureWidget({
    Key? key,
    required this.selectedImage,
    required this.imageUrl,
    required this.onPickImage,
    required this.isEditing,
  }) : super(key: key);

  void _viewFullImage(BuildContext context) {
    if (selectedImage != null || imageUrl != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenImage(
            imageFile: selectedImage,
            imageUrl: imageUrl,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double avatarRadius = screenWidth * 0.25;
    double maxHeight = screenHeight * 0.25; // 25% of screen height
    avatarRadius = avatarRadius.clamp(50, maxHeight); // Ensure it doesn't exceed max height

    return Center(
      child: GestureDetector(
        onTap: isEditing ? onPickImage : () => _viewFullImage(context),
        child: Hero(
          tag: "profile_picture",
          child: CircleAvatar(
            radius: avatarRadius,
            backgroundImage: selectedImage != null
                ? FileImage(selectedImage!)
                : (imageUrl != null
                    ? NetworkImage(imageUrl!)
                    : const AssetImage("assets/default-avatar.png")),
            child: isEditing
                ? Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.5),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 30,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}


class FullScreenImage extends StatelessWidget {
  final File? imageFile;
  final String? imageUrl;

  const FullScreenImage({
    Key? key,
    this.imageFile,
    this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Hero(
          tag: "profile_picture",
          child: AspectRatio(
            aspectRatio: 1,
            child: ClipRect(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageFile != null
                        ? FileImage(imageFile!)
                        : NetworkImage(imageUrl!) as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}