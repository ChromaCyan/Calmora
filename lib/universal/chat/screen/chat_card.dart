import 'package:flutter/material.dart';

class ChatCard extends StatelessWidget {
  final String chatId;
  final String recipientId;
  final String recipientName;
  final String lastMessage;
  final VoidCallback onTap;

  const ChatCard({
    Key? key,
    required this.chatId,
    required this.recipientId,
    required this.recipientName,
    required this.lastMessage,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
  margin: const EdgeInsets.symmetric(vertical: 6),
  // decoration: BoxDecoration(
  //   border: Border.all(
  //     color: theme.colorScheme.outline, // Border color from theme
  //     width: 1.5, // Border thickness
  //   ),
  // ),
  color: theme.colorScheme.background, // Solid background

  child: ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    leading: CircleAvatar(
      radius: 45, // Increased size (default was 24)
      backgroundColor: theme.colorScheme.primary.withOpacity(0.3),
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 45, // Increased icon size (default was smaller)
      ),
    ),
    title: Text(
      recipientName,
      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
    ),
    subtitle: Text(
      lastMessage,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(0.6),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    onTap: onTap,
  ),
);
  }
}
