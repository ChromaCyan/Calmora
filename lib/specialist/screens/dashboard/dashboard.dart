import 'dart:ui';
import 'package:armstrong/specialist/screens/dashboard/chart/WeeklyAppointment.dart';
import 'package:flutter/material.dart';
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

      var closestAccepted = fetchedAppointments
          .where((appointment) => appointment['status'] == 'accepted')
          .map((appointment) {
        var appointmentDate = DateTime.parse(appointment['appointmentDate']);
        var startTime =
            DateFormat('hh:mm a').parse(appointment['timeSlot']['startTime']);

        var fullAppointmentTime = DateTime(
          appointmentDate.year,
          appointmentDate.month,
          appointmentDate.day,
          startTime.hour,
          startTime.minute,
        );

        var difference = fullAppointmentTime.isBefore(now)
            ? Duration.zero
            : fullAppointmentTime.difference(now);

        return {
          'appointment': appointment,
          'fullAppointmentTime': fullAppointmentTime,
          'difference': difference,
        };
      }).toList();

      closestAccepted.sort((a, b) => a['difference'].compareTo(b['difference']));

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
    final theme = Theme.of(context);

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor.withOpacity(0.6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📅 Upcoming Appointments
              Center(
                child: Text(
                  'Your Upcoming Appointments',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _buildUpcomingAppointments(),

              const SizedBox(height: 30),

              // 📊 Weekly Chart
              Center(
                child: Text(
                  'Weekly Appointment Chart',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              WeeklyAppointmentChart(specialistId: widget.specialistId),

              const SizedBox(height: 30),

              // ✨ (Optional) You could add a "Recommended Resources" or "Your Stats" section here later
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
      physics: const NeverScrollableScrollPhysics(),
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
