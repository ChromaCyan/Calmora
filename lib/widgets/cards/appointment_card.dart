import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:armstrong/services/api.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:armstrong/widgets/forms/reschedule_appointment_form.dart';

class AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final VoidCallback? onUpdated;

  const AppointmentCard({
    Key? key,
    required this.appointment,
    this.onUpdated,
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

  void _showSnackBar(BuildContext context, String title, String message, ContentType type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: title,
          message: message,
          contentType: type,
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _cancelAppointment(BuildContext context, String appointmentId) async {
    try {
      final api = ApiRepository();
      await api.cancelAppointment(appointmentId, "patient", "User requested cancellation");
      _showSnackBar(context, 'Appointment Cancelled', 'Your appointment has been successfully cancelled.', ContentType.warning);
      onUpdated?.call();
    } catch (e) {
      _showSnackBar(context, 'Error', 'Something went wrong while cancelling your appointment.', ContentType.failure);
    }
  }

  void _openRescheduleForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => RescheduleAppointmentForm(
        appointmentId: appointment['_id'],
        specialistId: appointment['specialist']['_id'],
        onRescheduled: onUpdated,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final specialist = appointment['specialist'];
    final specialistName = '${specialist['firstName']} ${specialist['lastName']}';
    final timeSlot = appointment['timeSlot'] ?? {};
    final status = appointment['status'] ?? 'unknown';

    final formattedStartTime = _formatTime(timeSlot['startTime'] ?? '');
    final formattedEndTime = _formatTime(timeSlot['endTime'] ?? '');
    final formattedCombinedTime = '$formattedStartTime - $formattedEndTime';
    final formattedStartDate = _formatDate(appointment['appointmentDate']);

    return Center(
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.04),
        width: screenWidth * 0.9,
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Name + Profile
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.02),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          specialistName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                            fontSize: screenWidth * 0.045,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Status: ${status[0].toUpperCase()}${status.substring(1)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: status == 'pending'
                                ? colorScheme.tertiary
                                : status == 'accepted'
                                    ? colorScheme.primary
                                    : colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.02),
                  child: Container(
                    height: screenWidth * 0.15,
                    width: screenWidth * 0.15,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: specialist['profileImage'] != null &&
                                specialist['profileImage'].isNotEmpty
                            ? NetworkImage(specialist['profileImage'])
                            : const AssetImage("images/no_profile3.png")
                                as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: screenHeight * 0.01),

            // Bottom: Date and Time
            Row(
              children: [
                _buildIconText(Icons.calendar_today, formattedStartDate, colorScheme),
                const SizedBox(width: 20),
                _buildIconText(Icons.access_time, formattedCombinedTime, colorScheme),
              ],
            ),

            // Actions: Cancel + Reschedule
            if (status == 'pending' || status == 'accepted' || status == 'rescheduled') ...[
              SizedBox(height: screenHeight * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _openRescheduleForm(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.015,
                          horizontal: screenWidth * 0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.schedule, color: Colors.white),
                    label: Text(
                      'Reschedule',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _cancelAppointment(context, appointment['_id']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.error,
                      padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.015,
                          horizontal: screenWidth * 0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.cancel, color: Colors.white),
                    label: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
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
