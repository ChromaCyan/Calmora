import 'package:flutter/material.dart';
import 'package:armstrong/config/colors.dart';

class CustomSearchBar extends StatefulWidget {
  final String hintText;
  final TextEditingController searchController;
  final Function(String) onChanged;
  final Function() onClear;
  final Function() onSearch;

  const CustomSearchBar({
    Key? key,
    required this.hintText,
    required this.searchController,
    required this.onChanged,
    required this.onClear,
    required this.onSearch,
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: widget.searchController,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: widget.hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          prefixIcon: _isSearching
              ? IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: orangeContainer),
            onPressed: () {
              FocusScope.of(context).unfocus();
              setState(() => _isSearching = false);
            },
          )
              : null,
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.search, color: Color.fromARGB(255, 171, 171, 171)),
                onPressed: null, 
              ),
              if (widget.searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, color: buttonColor),
                  onPressed: widget.onClear,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
