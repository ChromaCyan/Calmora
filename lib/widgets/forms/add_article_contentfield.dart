import 'package:flutter/material.dart';
import 'package:armstrong/widgets/navigation/appbar.dart';

class AddArticleContentFieldPage extends StatefulWidget {
  final String initialContent;

  const AddArticleContentFieldPage({Key? key, required this.initialContent}) : super(key: key);

  @override
  _AddArticleContentFieldPageState createState() => _AddArticleContentFieldPageState();
}

class _AddArticleContentFieldPageState extends State<AddArticleContentFieldPage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
  }

  void _handleDone() {
    Navigator.of(context).pop(_controller.text);
  }

  Future<bool> _onWillPop() async {
    // Return edited content even on system back
    Navigator.of(context).pop(_controller.text);
    return false; // prevent default pop as we handled it manually
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        appBar: AppBar(
          title: Text(""),
          // leading: IconButton(
          //   icon: Icon(Icons.arrow_back_ios_new_rounded),
          //   onPressed: _handleDone,
          //   color: theme.colorScheme.onPrimaryContainer,
          // ),
          // actions: [
          //   TextButton(
          //     onPressed: _handleDone,
          //     child: Text(
          //       'Done',
          //       style: TextStyle(
          //         color: theme.colorScheme.onPrimary,
          //         fontWeight: FontWeight.bold,
          //         fontSize: 16,
          //       ),
          //     ),
          //   ),
          // ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(0.0),
          child: TextFormField(
            controller: _controller,
            maxLines: null,
            expands: true,
            keyboardType: TextInputType.multiline,
            autofocus: true,
            cursorColor: theme.colorScheme.primary, // Optional
            style: TextStyle(
              fontSize: 16,
              color: theme.textTheme.bodyLarge?.color,
            ),
            decoration: InputDecoration(
              isCollapsed: true, // Removes extra padding
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Optional
              hintText: 'Write your article content here...',
              hintStyle: TextStyle(color: theme.hintColor),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              fillColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              filled: true,
            ),
          ),
        ),
      ),
    );
  }
}
