import 'package:flutter/material.dart';

class ToggleButton extends StatefulWidget {
  final Function(bool) onToggle;

  const ToggleButton({Key? key, required this.onToggle}) : super(key: key);

  @override
  _ToggleButtonState createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  bool isContactSelected = true;

  void _setSelection(bool isContact) {
    if (isContactSelected != isContact) {
      setState(() {
        isContactSelected = isContact;
        widget.onToggle(isContactSelected);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildButton(
          "Contacts",
          isContactSelected,
          true,
          theme.colorScheme.primary, // Primary color from theme
          theme.colorScheme.onPrimary, // Text color on primary
        ),
        _buildButton(
          "Profession",
          !isContactSelected,
          false,
          theme.colorScheme.primary, // Secondary color from theme
          theme.colorScheme.onPrimary, // Text color on secondary
        ),
      ],
    );
  }

  Widget _buildButton(
    String text,
    bool isSelected,
    bool isContact,
    Color selectedColor,
    Color textColor,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _setSelection(isContact),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : theme.cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? textColor : theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
