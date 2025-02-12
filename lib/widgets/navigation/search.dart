import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final String hintText;
  final TextEditingController searchController;
  final Function(String) onChanged;
  final Function() onClear;

  const CustomSearchBar({
    Key? key,
    required this.hintText,
    required this.searchController,
    required this.onChanged,
    required this.onClear,
  }) : super(key: key);

  @override
  _CustomSearchBarState createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final FocusNode _focusNode = FocusNode();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() => _isSearching = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TextField(
        controller: widget.searchController,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: widget.hintText,
          filled: true,
          fillColor: theme.colorScheme.surfaceVariant, // Background color
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: theme.colorScheme.outline, // Edge color from theme
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: theme.colorScheme.primary, // Highlighted color on focus
              width: 2,
            ),
          ),
          prefixIcon: _isSearching
              ? IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.primary),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    setState(() => _isSearching = false);
                  },
                )
              : Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant),
          suffixIcon: widget.searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: theme.colorScheme.secondary),
                  onPressed: widget.onClear,
                )
              : null,
        ),
      ),
    );
  }
}
