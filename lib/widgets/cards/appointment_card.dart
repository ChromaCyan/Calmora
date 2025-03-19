import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;

  const AppointmentCard({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  String _formatDate(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('MMM d, y').format(dateTime);
    } catch (e) {
      return "Invalid Date";
    }
  }

  String _formatTime(String timeString) {
    try {
      final time = DateFormat('h:mm a').parse(timeString);
      return DateFormat('h:mm a').format(time);
    } catch (e) {
      return "Invalid Time";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    final specialist = appointment['specialist'];
    final specialistName =
        '${specialist['firstName']} ${specialist['lastName']}';

    final timeSlot = appointment['timeSlot'] ?? {};
    final status = appointment['status'] ?? 'unknown';

    // Use timeSlot's start and end time
    final formattedStartTime = _formatTime(timeSlot['startTime'] ?? '');
    final formattedEndTime = _formatTime(timeSlot['endTime'] ?? '');
    final formattedCombinedTime = '$formattedStartTime - $formattedEndTime';

    // Use appointment's appointmentDate
    final formattedStartDate = _formatDate(appointment['appointmentDate']);

    return Center(
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.04),
        width: screenWidth * 0.9,
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.outlineVariant),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                ClipOval(
                  child: Image.network(
                    specialist['profileImage']?.isNotEmpty == true
                        ? specialist['profileImage']
                        : "https://via.placeholder.com/50",
                    width: screenWidth * 0.14,
                    height: screenWidth * 0.14,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
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
