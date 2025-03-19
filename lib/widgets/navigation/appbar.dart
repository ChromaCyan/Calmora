import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UniversalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;

  const UniversalAppBar({
    Key? key,
    required this.title,
    this.onBackPressed,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onPrimaryContainer),
        onPressed: onBackPressed ?? () => Navigator.pop(context),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w500,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      elevation: 2,
      backgroundColor: colorScheme.primaryContainer,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
