import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final bool isRequired;
  final VoidCallback? onTap;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.isRequired = true,
    this.onTap,
    this.readOnly = false,
    this.onChanged,
    this.focusNode,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _showError = false;
  String? _errorMessage;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_validateField);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    widget.controller.removeListener(_validateField);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {}); // Triggers a rebuild to update label behavior
  }

  void _validateField() {
    setState(() {
      String trimmedText = widget.controller.text.trim();
      if (widget.isRequired && trimmedText.isEmpty) {
        _showError = true;
        _errorMessage = "This is required";
      } else {
        _showError = false;
        _errorMessage = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          focusNode: _focusNode,
          onChanged: (value) {
            _validateField();
            if (widget.onChanged != null) widget.onChanged!(value);
          },
          decoration: InputDecoration(
            labelText: widget.label,
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            labelStyle: TextStyle(
              color: _showError ? Colors.white : theme.colorScheme.onSurface,
            ),
            floatingLabelStyle: TextStyle(
              color: _showError ? Colors.white : theme.colorScheme.primary,
            ),
            filled: true,
            fillColor: theme.colorScheme.background,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: _showError ? Colors.red : theme.colorScheme.primary,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: _showError ? Colors.red : theme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            errorText: _showError ? _errorMessage : null,
            errorStyle: TextStyle(color: Colors.red, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
