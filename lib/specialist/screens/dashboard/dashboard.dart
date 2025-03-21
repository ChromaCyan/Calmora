import 'package:armstrong/specialist/screens/dashboard/chart/WeeklyAppointment.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:armstrong/widgets/cards/specialist_appointment_card.dart';
import 'package:armstrong/services/api.dart';
import 'package:intl/intl.dart';

class SpecialistDashboardScreen extends StatefulWidget {
  final String specialistId;

  const SpecialistDashboardScreen({required this.specialistId, Key? key})
      : super(key: key);

  @override
  _SpecialistDashboardScreenState createState() =>
      _SpecialistDashboardScreenState();
}

class _SpecialistDashboardScreenState extends State<SpecialistDashboardScreen> {
  List<dynamic> upcomingAppointments = [];
  bool isLoading = true;
  String errorMessage = '';
  final ApiRepository _apiRepository = ApiRepository();

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    try {
      final fetchedAppointments =
          await _apiRepository.getSpecialistAppointments(widget.specialistId);
      var now = DateTime.now();

      // Filter and map the appointments based on status and time
      var closestAccepted = fetchedAppointments
          .where((appointment) => appointment['status'] == 'accepted')
          .map((appointment) {
        var appointmentDate = DateTime.parse(appointment['appointmentDate']);
        var startTime =
            DateFormat('hh:mm a').parse(appointment['timeSlot']['startTime']);

        // Combine the date and time into a full DateTime
        var fullAppointmentTime = DateTime(
          appointmentDate.year,
          appointmentDate.month,
          appointmentDate.day,
          startTime.hour,
          startTime.minute,
        );

        // Calculate the difference from now to the appointment time
        var difference = fullAppointmentTime.isBefore(now)
            ? Duration.zero
            : fullAppointmentTime.difference(now);
        return {
          'appointment': appointment,
          'fullAppointmentTime': fullAppointmentTime,
          'difference': difference,
        };
      }).toList();

      // Sort by the closest appointment (time difference)
      closestAccepted
          .sort((a, b) => a['difference'].compareTo(b['difference']));

      setState(() {
        upcomingAppointments =
            closestAccepted.map((e) => e['appointment']).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.center,
                child: const Text(
                  'Your Upcoming Appointments',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              _buildUpcomingAppointments(),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: const Text(
                  'Appointment Chart (Weekly)',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              WeeklyAppointmentChart(specialistId: widget.specialistId),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingAppointments() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (errorMessage.isNotEmpty) {
      return Center(child: Text('Error: $errorMessage'));
    } else if (upcomingAppointments.isEmpty) {
      return const Center(child: Text('No upcoming appointments.'));
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: upcomingAppointments.length,
      itemBuilder: (context, index) {
        final appointment = upcomingAppointments[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SpecialistAppointmentCard(
            appointment: appointment,
            onStatusChanged: _fetchAppointments,
          ),
        );
      },
    );
  }
}
