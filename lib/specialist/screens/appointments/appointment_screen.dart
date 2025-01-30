import 'package:armstrong/config/colors.dart';
import 'package:armstrong/services/api.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_bloc.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_state.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_event.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SpecialistAppointmentListScreen extends StatefulWidget {
  final String specialistId;

  const SpecialistAppointmentListScreen({required this.specialistId, Key? key})
      : super(key: key);

  @override
  _SpecialistAppointmentListScreenState createState() =>
      _SpecialistAppointmentListScreenState();
}

class _SpecialistAppointmentListScreenState
    extends State<SpecialistAppointmentListScreen> {
  String _formatDate(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    return DateFormat('MMM d, y').format(dateTime);
  }

  String _formatTime(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    return DateFormat('h:mm a').format(dateTime);
  }

  // Combine start and end times into one string
  String _combineDateTimes(
      String startDateTimeString, String endDateTimeString) {
    final startDateTime = DateTime.parse(startDateTimeString);
    final endDateTime = DateTime.parse(endDateTimeString);

    final startFormatted = _formatTime(startDateTimeString);
    final endFormatted = _formatTime(endDateTimeString);

    return '$startFormatted - $endFormatted';
  }

  @override
  void initState() {
    super.initState();
    // Trigger event to fetch specialist appointments when the screen is loaded
    context.read<AppointmentBloc>().add(FetchSpecialistAppointmentsEvent(
          specialistId: widget.specialistId,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AppointmentBloc, AppointmentState>(
        builder: (context, state) {
          if (state is AppointmentLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is AppointmentError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is SpecialistAppointmentsLoaded) {
            final appointments = state.appointments
                .where((appointment) => appointment['status'] != 'declined')
                .toList();

            if (appointments.isEmpty) {
              return Center(child: Text('No appointments found.'));
            }
            if (state is AppointmentAccepted || state is AppointmentDeclined) {
              context
                  .read<AppointmentBloc>()
                  .add(FetchSpecialistAppointmentsEvent(
                    specialistId: widget.specialistId,
                  ));
            }

            return ListView.builder(
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                final patient = appointment['patient'];
                final patientName =
                    '${patient['firstName']} ${patient['lastName']}';
                final startTime = appointment['startTime'];
                final endTime = appointment['endTime'];
                final status = appointment['status'];
                final appointmentId = appointment['_id'];

                final timeRange = _combineDateTimes(startTime, endTime);
                final formattedStartDate = _formatDate(startTime);

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                  shadowColor: Colors.black.withOpacity(0.1),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patientName,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                color: Colors.orange, size: 18.0),
                            SizedBox(width: 8.0),
                            Text('Date: $formattedStartDate',
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.black54)),
                          ],
                        ),
                        SizedBox(height: 8.0),
                        Row(
                          children: [
                            Icon(Icons.lock_clock,
                                color: Colors.blue, size: 18.0),
                            SizedBox(width: 8.0),
                            Text('Time: $timeRange',
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.black54)),
                          ],
                        ),
                        SizedBox(height: 8.0),
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
                        SizedBox(height: 8.0),
                        if (status == 'pending') ...[
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  context.read<AppointmentBloc>().add(
                                      AcceptAppointmentEvent(
                                          appointmentId: appointmentId));
                                },
                                child: Text('Accept'),
                              ),
                              SizedBox(width: 8.0),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<AppointmentBloc>().add(
                                      DeclineAppointmentEvent(
                                          appointmentId: appointmentId));
                                },
                                child: Text('Decline'),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                              ),
                            ],
                          ),
                        ]
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return Center(child: Text('Unexpected state.'));
        },
      ),
    );
  }
}
