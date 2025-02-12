import 'package:armstrong/specialist/screens/appointments/appointment_complete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_bloc.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_event.dart';
import 'package:armstrong/services/api.dart'; 

class SpecialistAppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final ApiRepository _apiRepository = ApiRepository();
  final VoidCallback onStatusChanged;

  SpecialistAppointmentCard({
    required this.appointment,
    required this.onStatusChanged,
  });

  String _formatDate(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    return DateFormat('MMM d, y').format(dateTime);
  }

  String _formatTime(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    return DateFormat('h:mm a').format(dateTime);
  }

  String _combineDateTimes(String startDateTimeString, String endDateTimeString) {
    final startFormatted = _formatTime(startDateTimeString);
    final endFormatted = _formatTime(endDateTimeString);
    return '$startFormatted - $endFormatted';
  }

  Future<void> _acceptAppointment(BuildContext context, String appointmentId) async {
    try {
      await _apiRepository.acceptAppointment(appointmentId);
      onStatusChanged(); // Refresh the appointment list after accepting
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error accepting appointment')));
    }
  }

  Future<void> _declineAppointment(BuildContext context, String appointmentId) async {
    try {
      await _apiRepository.declineAppointment(appointmentId);
      onStatusChanged(); // Refresh the appointment list after declining
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error declining appointment')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final patient = appointment['patient'];
    final patientName = '${patient['firstName']} ${patient['lastName']}';
    final startTime = appointment['startTime'];
    final endTime = appointment['endTime'];
    final status = appointment['status'];
    final appointmentId = appointment['_id'];

    final timeRange = _combineDateTimes(startTime, endTime);
    final formattedStartDate = _formatDate(startTime);

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
          mainAxisSize: MainAxisSize.min,
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
                          patientName,
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: theme.primary,
                      shape: BoxShape.circle,
                      image: const DecorationImage(
                        image: AssetImage("images/splash/logo_placeholder.png"),
                        filterQuality: FilterQuality.high,
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
                  style: TextStyle(fontSize: 16.0, color: theme.onSurfaceVariant),
                ),
                const SizedBox(width: 12.0),
                Icon(Icons.access_time, color: theme.secondary, size: 18.0),
                const SizedBox(width: 8.0),
                Text(
                  timeRange,
                  style: TextStyle(fontSize: 16.0, color: theme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            if (status == 'pending') ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _acceptAppointment(context, appointmentId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Accept', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _declineAppointment(context, appointmentId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.error,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Decline', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
            if (status == 'accepted') ...[
              const SizedBox(height: 12.0),
              ElevatedButton(
                onPressed: () {
                  // Navigate to the AppointmentCompleteScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppointmentCompleteScreen(appointmentId: appointmentId),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Proceed to Complete', style: TextStyle(color: Colors.white)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
