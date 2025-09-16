import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;

  const AppointmentCard({Key? key, required this.appointment}) : super(key: key);

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    final specialist = appointment['specialist'];
    final specialistName =
        '${specialist['firstName']} ${specialist['lastName']}';

    final timeSlot = appointment['timeSlot'] ?? {};
    final status = appointment['status'] ?? 'unknown';

    final formattedStartTime = _formatTime(timeSlot['startTime'] ?? '');
    final formattedEndTime = _formatTime(timeSlot['endTime'] ?? '');
    final formattedCombinedTime = '$formattedStartTime - $formattedEndTime';

    final formattedStartDate = _formatDate(appointment['appointmentDate']);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Name + Profile
          Row(
            children: [
              Expanded(
                child: Text(
                  specialistName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              CircleAvatar(
                backgroundImage: NetworkImage(
                  specialist['profileImage']?.isNotEmpty == true
                      ? specialist['profileImage']
                      : 'https://via.placeholder.com/150',
                ),
                radius: 24,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Status: ${status[0].toUpperCase()}${status.substring(1)}',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: status == 'pending'
                  ? colorScheme.tertiary
                  : status == 'accepted'
                      ? colorScheme.primary
                      : colorScheme.error,
            ),
          ),
          const SizedBox(height: 12),

          // Bottom: Date and Time
          Row(
            children: [
              _buildIconText(Icons.calendar_today, formattedStartDate, colorScheme),
              const SizedBox(width: 20),
              _buildIconText(Icons.access_time, formattedCombinedTime, colorScheme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text, ColorScheme scheme) {
    return Row(
      children: [
        Icon(icon, color: scheme.primary, size: 18),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
