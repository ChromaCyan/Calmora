import 'package:flutter/material.dart';

class TextNSend extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const TextNSend({
    Key? key,
    required this.controller,
    required this.onSend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send_rounded, color: theme.primary),
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}
