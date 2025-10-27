import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:armstrong/services/api.dart';
import 'package:armstrong/specialist/screens/appointments/appointment_complete.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:armstrong/widgets/forms/reschedule_appointment_form.dart';

class SpecialistAppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final ApiRepository _apiRepository = ApiRepository();
  final VoidCallback onStatusChanged;

  SpecialistAppointmentCard({
    required this.appointment,
    required this.onStatusChanged,
  });

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

  String _combineDateTimes(String startTimeString, String endTimeString) {
    final formattedStartTime = _formatTime(startTimeString);
    final formattedEndTime = _formatTime(endTimeString);
    return '$formattedStartTime - $formattedEndTime';
  }

  void _showSnackBar(
      BuildContext context, String title, String message, ContentType type) {
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

  Future<void> _acceptAppointment(
      BuildContext context, String appointmentId) async {
    try {
      await _apiRepository.acceptAppointment(appointmentId);
      onStatusChanged();
      _showSnackBar(
          context,
          "Appointment Accepted",
          "You have successfully accepted this appointment.",
          ContentType.success);
    } catch (e) {
      _showSnackBar(context, "Error", "Failed to accept appointment.",
          ContentType.failure);
    }
  }

  Future<void> _declineAppointment(
      BuildContext context, String appointmentId) async {
    try {
      await _apiRepository.declineAppointment(appointmentId);
      onStatusChanged();
      _showSnackBar(context, "Appointment Declined",
          "You have declined this appointment.", ContentType.warning);
    } catch (e) {
      _showSnackBar(context, "Error", "Failed to decline appointment.",
          ContentType.failure);
    }
  }

  Future<void> _cancelAppointment(
      BuildContext context, String appointmentId) async {
    try {
      await _apiRepository.cancelAppointment(
          appointmentId, "specialist", "Schedule conflict");
      onStatusChanged();
      _showSnackBar(
          context,
          "Appointment Cancelled",
          "The appointment has been successfully cancelled.",
          ContentType.warning);
    } catch (e) {
      _showSnackBar(
          context,
          "Error",
          "Error cancelling appointment. Please try again.",
          ContentType.failure);
    }
  }

  void _openRescheduleForm(
      BuildContext context, String appointmentId, String specialistId) {
    showDialog(
      context: context,
      builder: (context) => RescheduleAppointmentForm(
        appointmentId: appointmentId,
        specialistId: specialistId,
        onRescheduled: onStatusChanged,
      ),
    );
  }

  void _onMenuSelected(
      BuildContext context, String action, String appointmentId) {
    switch (action) {
      case 'accept':
        _acceptAppointment(context, appointmentId);
        break;
      case 'decline':
        _declineAppointment(context, appointmentId);
        break;
      case 'cancel':
        _cancelAppointment(context, appointmentId);
        break;
      case 'complete':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AppointmentCompleteScreen(appointmentId: appointmentId),
          ),
        ).then((_) {
          onStatusChanged();
        });
        break;

      case 'reschedule':
        _openRescheduleForm(context, appointmentId, appointment['specialist']);
        break;
    }
  }

  List<PopupMenuEntry<String>> _buildMenuOptions(String status) {
    if (status == 'pending') {
      return [
        const PopupMenuItem(value: 'accept', child: Text('Accept')),
        const PopupMenuItem(value: 'decline', child: Text('Decline')),
      ];
    } else if (status == 'accepted') {
      return [
        const PopupMenuItem(
            value: 'complete', child: Text('Proceed to Complete')),
        const PopupMenuItem(value: 'reschedule', child: Text('Reschedule')),
        const PopupMenuItem(value: 'cancel', child: Text('Cancel')),
      ];
    } else if (status == 'rescheduled') {
      return [
        const PopupMenuItem(
            value: 'complete', child: Text('Proceed to Complete')),
        const PopupMenuItem(value: 'reschedule', child: Text('Reschedule')),
        const PopupMenuItem(value: 'cancel', child: Text('Cancel')),
      ];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final patient = appointment['patient'];
    final patientName = '${patient['firstName']} ${patient['lastName']}';
    final timeSlot = appointment['timeSlot'] ?? {};
    final status = appointment['status'] ?? 'pending';
    final appointmentId = appointment['_id'];

    final formattedStartDate = _formatDate(appointment['appointmentDate']);
    final timeRange = _combineDateTimes(
        timeSlot['startTime'] ?? '', timeSlot['endTime'] ?? '');

    return Center(
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.04),
        width: screenWidth * 0.9,
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: colorScheme.outlineVariant.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Patient Name + Status
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.02),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patientName,
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Status: ${status[0].toUpperCase() + status.substring(1)}',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                            color: status == 'pending'
                                ? colorScheme.tertiary
                                : colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Patient Profile
                CircleAvatar(
                  radius: screenWidth * 0.075,
                  backgroundImage: (patient['profileImage'] != null &&
                          patient['profileImage'].isNotEmpty)
                      ? NetworkImage(patient['profileImage'])
                      : const AssetImage("images/no_profile3.png")
                          as ImageProvider,
                ),
                const SizedBox(width: 2),
                // Settings Icon for menu
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, size: screenWidth * 0.07),
                  onSelected: (value) =>
                      _onMenuSelected(context, value, appointmentId),
                  itemBuilder: (context) => _buildMenuOptions(status),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.01),
            // Date and Time
            Row(
              children: [
                Icon(Icons.calendar_today,
                    color: colorScheme.primary, size: screenWidth * 0.04),
                SizedBox(width: screenWidth * 0.02),
                Text(formattedStartDate,
                    style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: colorScheme.onSurfaceVariant)),
                SizedBox(width: screenWidth * 0.05),
                Icon(Icons.access_time,
                    color: colorScheme.secondary, size: screenWidth * 0.04),
                SizedBox(width: screenWidth * 0.02),
                Text(timeRange,
                    style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
