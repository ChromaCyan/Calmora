import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:armstrong/config/colors.dart';

class UniversalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;

  const UniversalAppBar({
    Key? key,
    required this.title,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: onBackPressed ?? () => Navigator.pop(context),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 17,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: orangeContainer, 
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}