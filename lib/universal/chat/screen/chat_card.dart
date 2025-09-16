import 'package:flutter/material.dart';

class ChatCard extends StatelessWidget {
  final String chatId;
  final String recipientId;
  final String recipientName;
  final String recipientImage;
  final String lastMessage;
  final VoidCallback onTap;

  const ChatCard({
    Key? key,
    required this.chatId,
    required this.recipientId,
    required this.recipientName,
    required this.recipientImage,
    required this.lastMessage,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: onTap,
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: theme.colorScheme.primary.withOpacity(0.3),
          backgroundImage: recipientImage.isNotEmpty ? NetworkImage(recipientImage) : null,
          child: recipientImage.isEmpty
              ? const Icon(Icons.person, color: Colors.white, size: 28)
              : null,
        ),
        title: Text(
          recipientName,
          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          lastMessage,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
      ),
    );
  }
}
