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
  final Widget? suffixIcon;
  final TextInputType? keyboardtype;

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
    this.suffixIcon,
    this.keyboardtype,
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
    final isDarkMode = theme.brightness == Brightness.dark;

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
              color: isDarkMode ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6),
            ),
            floatingLabelStyle: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
            filled: true,
            fillColor: theme.colorScheme.background.withOpacity(0.6),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(
                color: Colors.transparent,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(
                color: _showError ? Colors.red : Colors.transparent,
                // width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),

            errorText: null,
            suffixIcon: widget.suffixIcon,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
          ),
        ),

         // Custom error message below, with fixed height
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 20, // Reserve fixed height
          alignment: Alignment.centerLeft,
          child: _showError
              ? Text(
                  _errorMessage ?? '',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                    height: 1.2,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }



  
  // @override
  // Widget build(BuildContext context) {
  //   final theme = Theme.of(context);
  //   final isDarkMode = theme.brightness == Brightness.dark;

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       TextFormField(
  //         controller: widget.controller,
  //         obscureText: widget.obscureText,
  //         readOnly: widget.readOnly,
  //         onTap: widget.onTap,
  //         focusNode: _focusNode,
  //         keyboardType: widget.keyboardtype,
  //         onChanged: (value) {
  //           _validateField();
  //           if (widget.onChanged != null) widget.onChanged!(value);
  //         },
  //         decoration: InputDecoration(
  //           labelText: widget.label,
  //           floatingLabelBehavior: FloatingLabelBehavior.auto,
  //           labelStyle: TextStyle(
  //             color: isDarkMode ? Colors.white : Colors.black,
  //           ),
  //           floatingLabelStyle: TextStyle(
  //             color: isDarkMode ? Colors.white70 : Colors.black87,
  //           ),
  //           // 🔑 Explicitly set filled to false
  //           filled: false,

  //           // 🔑 Set background color explicitly to transparent (just in case)
  //           fillColor: Colors.transparent,

  //           // 🔄 Replace all OutlineInputBorder with UnderlineInputBorder
  //           enabledBorder: UnderlineInputBorder(
  //             borderSide: BorderSide(
  //               color: _showError ? Colors.red : theme.colorScheme.primary,
  //               width: 1.5,
  //             ),
  //           ),
  //           focusedBorder: UnderlineInputBorder(
  //             borderSide: BorderSide(
  //               color: _showError ? Colors.red : theme.colorScheme.primary,
  //               width: 2.0,
  //             ),
  //           ),
  //           errorBorder: UnderlineInputBorder(
  //             borderSide: const BorderSide(
  //               color: Colors.red,
  //               width: 1.5,
  //             ),
  //           ),
  //           focusedErrorBorder: UnderlineInputBorder(
  //             borderSide: const BorderSide(
  //               color: Colors.red,
  //               width: 2.0,
  //             ),
  //           ),

  //           // errorText: _showError ? _errorMessage : null,
  //           // errorStyle: const TextStyle(color: Colors.red, fontSize: 14),
  //           // suffixIcon: widget.suffixIcon,
  //           // suffixIconConstraints: const BoxConstraints(
  //           //   minWidth: 40,
  //           //   minHeight: 40,
  //           // ),


  //            // Don’t show the built-in error text
  //           errorText: null,
  //           suffixIcon: widget.suffixIcon,
  //           suffixIconConstraints: const BoxConstraints(
  //             minWidth: 40,
  //             minHeight: 40,
  //           ),
  //         ),
  //       ),

  //        // Custom error message below, with fixed height
  //       AnimatedContainer(
  //         duration: const Duration(milliseconds: 200),
  //         height: 18, // Reserve fixed height
  //         alignment: Alignment.centerLeft,
  //         child: _showError
  //             ? Text(
  //                 _errorMessage ?? '',
  //                 style: const TextStyle(
  //                   color: Colors.red,
  //                   fontSize: 13,
  //                   height: 1.2,
  //                 ),
  //               )
  //             : const SizedBox.shrink(),
  //       ),
  //     ],
  //   );
  // }
}
