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
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double textScale = MediaQuery.of(context).textScaleFactor;

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: screenHeight * 0.008, // Keeps some vertical spacing
      ),
      color: theme.colorScheme.surface, // No border radius & No shadow
      child: ListTile(
        onTap: onTap,
        leading: SizedBox(
          width: 55, // Fixed width to prevent resizing
          height: 55, // Fixed height to prevent resizing
          child: ClipOval(
            child: recipientImage.isNotEmpty
                ? Image.network(
                    recipientImage,
                    width: 55,
                    height: 55,
                    fit: BoxFit.cover, // Ensures the image does not stretch or zoom
                    errorBuilder: (context, error, stackTrace) => _buildPlaceholder(theme),
                  )
                : _buildPlaceholder(theme),
          ),
        ),
        title: Text(
          recipientName,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16 * textScale,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          lastMessage,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontSize: 14 * textScale,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }

  /// Placeholder for missing or error images
  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, color: Colors.white, size: 28),
    );
  }
}
