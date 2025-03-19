import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:armstrong/services/api.dart';
import 'package:armstrong/specialist/screens/appointments/appointment_complete.dart';

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

  Future<void> _acceptAppointment(
      BuildContext context, String appointmentId) async {
    try {
      await _apiRepository.acceptAppointment(appointmentId);
      onStatusChanged();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error accepting appointment')),
      );
    }
  }

  Future<void> _declineAppointment(
      BuildContext context, String appointmentId) async {
    try {
      await _apiRepository.declineAppointment(appointmentId);
      onStatusChanged();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error declining appointment')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final specialistId =
        appointment['specialist']; // This is the ID, not the object
    final specialistName = specialistId != null
        ? 'Loading Specialist...' // You should show a loading indicator or fetch specialist details from an API
        : 'Specialist';
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
          color: theme.surface,
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          border: Border.all(color: theme.outlineVariant),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
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
                            color: theme.onSurface,
                          ),
                        ),
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
                ),
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.02),
                  child: Container(
                    height: screenWidth * 0.15,
                    width: screenWidth * 0.15,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: patient['profileImage'] != null &&
                                patient['profileImage'].isNotEmpty
                            ? NetworkImage(patient['profileImage'])
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
            SizedBox(height: screenHeight * 0.01),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    color: theme.primary, size: screenWidth * 0.04),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  formattedStartDate,
                  style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: theme.onSurfaceVariant),
                ),
                SizedBox(width: screenWidth * 0.05),
                Icon(Icons.access_time,
                    color: theme.secondary, size: screenWidth * 0.04),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  timeRange,
                  style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: theme.onSurfaceVariant),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.015),
            if (status == 'pending') ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          _acceptAppointment(context, appointmentId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.02),
                        ),
                      ),
                      child: Text(
                        'Accept',
                        style: TextStyle(
                            color: Colors.white, fontSize: screenWidth * 0.04),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          _declineAppointment(context, appointmentId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.error,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.02),
                        ),
                      ),
                      child: Text(
                        'Decline',
                        style: TextStyle(
                            color: Colors.white, fontSize: screenWidth * 0.04),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (status == 'accepted') ...[
              SizedBox(height: screenHeight * 0.015),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppointmentCompleteScreen(
                          appointmentId: appointmentId),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  ),
                ),
                child: Text(
                  'Proceed to Complete',
                  style: TextStyle(
                      color: Colors.white, fontSize: screenWidth * 0.04),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
