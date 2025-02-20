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
    final specialist = appointment['specialist'];
    final specialistName =
        '${specialist['firstName']} ${specialist['lastName']}';
    final specialistProfile = '${specialist['profileImage']}';
    final startTime = appointment['startTime'];
    final endTime = appointment['endTime'];
    final status = appointment['status'];

    final formattedStartDate = _formatDate(startTime);
    final formattedStartTime = _formatTime(startTime);
    final formattedEndTime = _formatTime(endTime);
    final formattedCombinedTime = '$formattedStartTime - $formattedEndTime';

    return Center(
      child: Container(
        padding: const EdgeInsets.all(12),
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.outlineVariant),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Allows dynamic height adjustment
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          specialistName,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: theme.onSurface,
                          ),
                        ),
                        Text(
                          'Status: ${status[0].toUpperCase() + status.substring(1)}',
                          style: TextStyle(
                            fontSize: 16.0,
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
                ),

                // SPECIALIST PROFILE IMAGE
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: specialist['profileImage'] != null &&
                                specialist['profileImage'].isNotEmpty
                            ? NetworkImage(specialist[
                                'profileImage']) 
                            : const AssetImage(
                                    "lib/icons/profile_placeholder.png")
                                as ImageProvider, 
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, color: theme.primary, size: 18.0),
                const SizedBox(width: 8.0),
                Text(
                  formattedStartDate,
                  style:
                      TextStyle(fontSize: 16.0, color: theme.onSurfaceVariant),
                ),
                const SizedBox(width: 12.0),
                Icon(Icons.lock_clock, color: theme.secondary, size: 18.0),
                const SizedBox(width: 8.0),
                Text(
                  formattedCombinedTime,
                  style:
                      TextStyle(fontSize: 16.0, color: theme.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
