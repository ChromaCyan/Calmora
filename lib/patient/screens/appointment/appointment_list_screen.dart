import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_bloc.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_event.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_state.dart';
import 'package:armstrong/services/api.dart';
import 'package:armstrong/widgets/cards/appointment_card.dart'; // Import the extracted UI component

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
    context.read<AppointmentBloc>().add(FetchPatientAppointmentsEvent(
          patientId: widget.patientId,
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
          } else if (state is PatientAppointmentsLoaded) {
            final appointments = state.appointments
                .where((appointment) => appointment['status'] != 'declined')
                .toList();

            if (appointments.isEmpty) {
              return Center(child: Text('No appointments found.'));
            }

            return ListView.builder(
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                return AppointmentCard(appointment: appointments[index]);
              },
            );
          }

          return Center(child: Text('Unexpected state.'));
        },
      ),
    );
  }
}
