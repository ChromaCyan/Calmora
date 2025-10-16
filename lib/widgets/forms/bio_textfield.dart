// lib/screens/edit_bio_page.dart

import 'package:flutter/material.dart';
import 'dart:ui';

class EditBioPage extends StatefulWidget {
  final String initialBio;

  const EditBioPage({Key? key, required this.initialBio}) : super(key: key);

  @override
  _EditBioPageState createState() => _EditBioPageState();
}

class _EditBioPageState extends State<EditBioPage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialBio);
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
          elevation: 1,
          backgroundColor: Colors.transparent,
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
              child: Container(
                color: theme.colorScheme.surface.withOpacity(0.6),
              ),
            ),
          ),
          title: Text(
            "Your Bio",
            style: TextStyle(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: _handleDone,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        body: TextFormField(
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
            hintText: 'Write here...',
            hintStyle: TextStyle(color: theme.hintColor),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            fillColor: Colors.transparent,
          ),
        ),
      ),
    );
  }
}
