import 'package:flutter/material.dart';
import 'package:armstrong/widgets/buttons/back_button.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool hasBackButton;
  final VoidCallback? onBackButtonPressed;
  final List<Widget>? actions;

  CustomAppBar({
    required this.title,
    this.hasBackButton = false,
    this.onBackButtonPressed,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color.fromARGB(255, 15, 100, 70),
      title: Text(title),
      centerTitle: true,
      leading: hasBackButton
          ? CustomBackButton(
              onPressed: onBackButtonPressed ?? () => Navigator.of(context).pop(),
              color: Colors.white,
              iconSize: 28.0,
            )
          : null, 
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
