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
    final scheme = Theme.of(context).colorScheme;

    // Subtle colors for different states
    Color statusColor;
    switch (status) {
      case 'sending':
        statusColor = Colors.grey;
        break;
      case 'failed':
        statusColor = Colors.redAccent;
        break;
      case 'delivered':
        statusColor = scheme.primary.withOpacity(0.7);
        break;
      case 'read':
        statusColor = scheme.primary;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isSender
              ? scheme.primary.withOpacity(0.1)
              : scheme.surfaceVariant.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(1, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isSender)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  senderName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: scheme.primary.withOpacity(0.8),
                  ),
                ),
              ),
            Text(
              content,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timestamp,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                if (isSender && status.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _statusText(status),
                      key: ValueKey(status),
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _statusText(String status) {
    switch (status) {
      case 'sending':
        return 'Sending...';
      case 'failed':
        return 'Failed to send';
      case 'delivered':
        return 'Delivered';
      case 'read':
        return 'Read';
      default:
        return '';
    }
  }
}
