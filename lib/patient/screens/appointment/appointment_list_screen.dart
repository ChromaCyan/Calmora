import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_bloc.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_event.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_state.dart';
import 'package:armstrong/services/api.dart';
import 'package:armstrong/config/colors.dart';

class AppointmentListScreen extends StatefulWidget {
  final String patientId;

  const AppointmentListScreen({required this.patientId, Key? key})
      : super(key: key);

  @override
  _AppointmentListScreenState createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  final ApiRepository _apiRepository = ApiRepository();

  @override
  void initState() {
    super.initState();
    // Ensure AppointmentBloc is provided correctly
    context.read<AppointmentBloc>().add(FetchPatientAppointmentsEvent(
          patientId: widget.patientId,
        ));
  }

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
    return Scaffold(
      body: BlocBuilder<AppointmentBloc, AppointmentState>(
        builder: (context, state) {
          if (state is AppointmentLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is AppointmentError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is PatientAppointmentsLoaded) {
            // Filter out declined appointments here
            final appointments = state.appointments
                .where((appointment) => appointment['status'] != 'declined')
                .toList();

            if (appointments.isEmpty) {
              return Center(child: Text('No appointments found.'));
            }

            return ListView.builder(
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                final specialist = appointment['specialist'];
                final specialistName =
                    '${specialist['firstName']} ${specialist['lastName']}';
                final startTime = appointment['startTime'];
                final endTime = appointment['endTime'];
                final status = appointment['status'];

                final formattedStartDate = _formatDate(startTime);
                final formattedStartTime = _formatTime(startTime);
                final formattedEndTime = _formatTime(endTime);
                final formattedCombinedTime =
                    '$formattedStartTime - $formattedEndTime';

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
                          specialistName,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: orangeContainer,
                              size: 18.0,
                            ),
                            SizedBox(width: 8.0),
                            Text(
                              'Date: $formattedStartDate',
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.black54),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.0),
                        Row(
                          children: [
                            Icon(
                              Icons.lock_clock,
                              color: buttonColor,
                              size: 18.0,
                            ),
                            SizedBox(width: 8.0),
                            Text(
                              'Time: $formattedCombinedTime',
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.black54),
                            ),
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
