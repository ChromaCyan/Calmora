import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;

  const AppointmentCard({Key? key, required this.appointment})
      : super(key: key);

  String _formatDate(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    return DateFormat('MMM d, y').format(dateTime);
  }

  String _formatTime(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    return DateFormat('h:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    final specialist = appointment['specialist'];
    final specialistName =
        '${specialist['firstName']} ${specialist['lastName']}';
    final startTime = appointment['startTime'];
    final endTime = appointment['endTime'];
    final status = appointment['status'];

    final formattedStartDate = _formatDate(startTime);
    final formattedStartTime = _formatTime(startTime);
    final formattedEndTime = _formatTime(endTime);
    final formattedCombinedTime = '$formattedStartTime - $formattedEndTime';

    return Center(
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.04), // Responsive padding
        width: screenWidth * 0.9, // 90% of screen width
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.outlineVariant),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Adapts to content size
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Specialist Name (Responsive Text)
                      Text(
                        specialistName,
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                          color: theme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),

                      const SizedBox(height: 4),

                      // Status with color-coded text
                      Text(
                        'Status: ${status[0].toUpperCase() + status.substring(1)}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w500,
                          color: status == 'pending'
                              ? theme.tertiary
                              : status == 'accepted'
                                  ? theme.primary
                                  : theme.error,
                        ),
                      ),
                    ],
                  ),
                ),

                // Profile Image (Responsive size)
                ClipOval(
                  child: Image.network(
                    specialist['profileImage'].isNotEmpty
                        ? specialist['profileImage']
                        : "https://via.placeholder.com/50", // Placeholder if empty
                    width: screenWidth * 0.14, // 14% of screen width
                    height: screenWidth * 0.14,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Date & Time Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildIconText(
                    Icons.calendar_today, formattedStartDate, theme, screenWidth),
                _buildIconText(
                    Icons.access_time, formattedCombinedTime, theme, screenWidth),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for icon + text layout
  Widget _buildIconText(IconData icon, String text, ColorScheme theme, double screenWidth) {
    return Row(
      children: [
        Icon(icon, color: theme.primary, size: screenWidth * 0.05),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: screenWidth * 0.04,
            color: theme.onSurfaceVariant,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
