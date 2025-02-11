import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_bloc.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_event.dart';

class SpecialistAppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;

  const SpecialistAppointmentCard({required this.appointment, Key? key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
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
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Name
            Text(
              patientName,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.0),

            // Date and Time
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.orange, size: 18.0),
                SizedBox(width: 6.0),
                Text(
                  formattedStartDate,
                  style: TextStyle(fontSize: 16.0, color: Colors.black54),
                ),
                SizedBox(width: 12.0),
                Icon(Icons.access_time, color: Colors.blue, size: 18.0),
                SizedBox(width: 6.0),
                Text(
                  timeRange,
                  style: TextStyle(fontSize: 16.0, color: Colors.black54),
                ),
              ],
            ),
            SizedBox(height: 12.0),

            // Status
            Text(
              'Status: ${status[0].toUpperCase() + status.substring(1)}',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                color: status == 'pending'
                    ? Colors.orange
                    : status == 'accepted'
                        ? Colors.green
                        : Colors.red,
              ),
            ),
            SizedBox(height: 12.0),

            // Action Buttons
            if (status == 'pending') ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context
                            .read<AppointmentBloc>()
                            .add(AcceptAppointmentEvent(appointmentId: appointmentId));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Accept', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  SizedBox(width: 12.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context
                            .read<AppointmentBloc>()
                            .add(DeclineAppointmentEvent(appointmentId: appointmentId));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Decline', style: TextStyle(color: Colors.white)),
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
}
