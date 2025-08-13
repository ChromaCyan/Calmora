import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String content;
  final String timestamp;
  final String status;
  final bool isSender;
  final String senderName;

  const ChatBubble({
    Key? key,
    required this.content,
    required this.timestamp,
    required this.status,
    required this.isSender,
    required this.senderName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color:
              isSender ? theme.primary.withOpacity(0.2) : theme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isSender)
              Text(senderName,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              content,
              style: const TextStyle(
                fontSize: 15, 
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(timestamp, style: const TextStyle(fontSize: 10)),
                const SizedBox(width: 4),
                Icon(
                  status == 'read' ? Icons.done_all : Icons.check,
                  size: 14,
                  color: status == 'read' ? Colors.blue : Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
