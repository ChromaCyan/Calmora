import 'package:flutter/material.dart';

class EditArticleContentFieldPage extends StatefulWidget {
  final String initialContent;

  const EditArticleContentFieldPage({Key? key, required this.initialContent}) : super(key: key);

  @override
  _EditArticleContentFieldPageState createState() => _EditArticleContentFieldPageState();
}

class _EditArticleContentFieldPageState extends State<EditArticleContentFieldPage> {
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
    Navigator.of(context).pop(_controller.text);
    return false; 
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        appBar: AppBar(
          title: const Text(""),
          // leading: IconButton(
          //   icon: const Icon(Icons.arrow_back_ios_new_rounded),
          //   onPressed: _handleDone,
          //   color: theme.colorScheme.onPrimaryContainer,
          // ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(0.0),
          child: TextFormField(
            controller: _controller,
            maxLines: null,
            expands: true,
            keyboardType: TextInputType.multiline,
            autofocus: true,
            cursorColor: theme.colorScheme.primary,
            style: TextStyle(
              fontSize: 16,
              color: theme.textTheme.bodyLarge?.color,
            ),
            decoration: InputDecoration(
              isCollapsed: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
