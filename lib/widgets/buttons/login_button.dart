import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class LoginButton extends StatelessWidget {
  final Function()? onTap;

  const LoginButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 55,
        decoration: BoxDecoration(
          color: isEnabled
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).disabledColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // const Icon(Icons.lock_outline, color: Colors.white),
            // const SizedBox(width: 8),
            Text(
              "LOG IN",
              style: GoogleFonts.montserrat(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
