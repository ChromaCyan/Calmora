import 'package:armstrong/config/colors.dart';
import 'package:armstrong/services/api.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_bloc.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_state.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_event.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/specialist/screens/appointments/specialist_appointment_card.dart'; // Import the new UI file

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

  String _combineDateTimes(String startDateTimeString, String endDateTimeString) {
    final startFormatted = _formatTime(startDateTimeString);
    final endFormatted = _formatTime(endDateTimeString);
    return '$startFormatted - $endFormatted';
  }

  @override
  void initState() {
    super.initState();
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
              context.read<AppointmentBloc>().add(
                FetchSpecialistAppointmentsEvent(specialistId: widget.specialistId),
              );
            }

            return ListView.builder(
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                final patient = appointment['patient'];
                final patientName = '${patient['firstName']} ${patient['lastName']}';
                final startTime = appointment['startTime'];
                final endTime = appointment['endTime'];
                final status = appointment['status'];
                final appointmentId = appointment['_id'];

                final timeRange = _combineDateTimes(startTime, endTime);
                final formattedStartDate = _formatDate(startTime);

                // Using SpecialistAppointmentCard to display each appointment
                // return SpecialistAppointmentCard(
                //   patientName: patientName,
                //   formattedStartDate: formattedStartDate,
                //   timeRange: timeRange,
                //   status: status,
                //   appointmentId: appointmentId,
                // );
                return SpecialistAppointmentCard(appointment: appointment);
              },
            );
          }
          return Center(child: Text('Unexpected state.'));
        },
      ),
    );
  }
}
