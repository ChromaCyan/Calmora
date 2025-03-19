import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_bloc.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_event.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_state.dart';
import 'package:armstrong/widgets/cards/appointment_card.dart';

class AppointmentListScreen extends StatefulWidget {
  final String patientId;

  const AppointmentListScreen({required this.patientId, Key? key})
      : super(key: key);

  @override
  _AppointmentListScreenState createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  String selectedCategory = 'pending';

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
            return const Center(child: CircularProgressIndicator());
          } else if (state is AppointmentError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is PatientAppointmentsLoaded) {
            final allAppointments = state.appointments
                .where((appointment) => appointment['status'] != 'declined')
                .toList();

            if (allAppointments.isEmpty) {
              return const Center(child: Text('No appointments found.'));
            }

            // Sort by nearest appointment
            allAppointments.sort((a, b) {
              final aTime = DateTime.parse(a['appointmentDate']);
              final bTime = DateTime.parse(b['appointmentDate']);
              return aTime.compareTo(bTime);
            });

            // Filter categories
            final upcomingAppointments = allAppointments
                .where((a) => a['status'] == 'upcoming')
                .toList();
            final pendingAppointments =
                allAppointments.where((a) => a['status'] == 'pending').toList();
            final acceptedAppointments = allAppointments
                .where((a) => a['status'] == 'accepted')
                .toList();

            // Select correct list based on category
            List filteredAppointments;
            if (selectedCategory == 'pending') {
              filteredAppointments = pendingAppointments;
            } else {
              filteredAppointments = acceptedAppointments;
            }

            return Column(
              children: [
                const SizedBox(height: 10),
                _buildCategorySelector(),
                const SizedBox(height: 10),
                Expanded(
                  child: filteredAppointments.isEmpty
                      ? const Center(child: Text('No appointments available.'))
                      : ListView.builder(
                          itemCount: filteredAppointments.length,
                          itemBuilder: (context, index) {
                            final appointment = filteredAppointments[index];
                            final timeSlot = appointment['timeSlot'] ?? {};

                            // Ensure startTime and endTime are parsed correctly as strings
                            final startTime =
                                timeSlot['startTime']?.toString() ?? 'N/A';
                            final endTime =
                                timeSlot['endTime']?.toString() ?? 'N/A';
                            final dayOfWeek =
                                timeSlot['dayOfWeek'] ?? 'Unknown';

                            // Pass the necessary fields to AppointmentCard
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: AppointmentCard(
                                appointment: appointment,
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }
          return const Center(child: Text('Unexpected state.'));
        },
      ),
    );
  }

  /// Full-width category selector
  Widget _buildCategorySelector() {
    return Row(
      children: [
        _buildCategoryButton('pending', 'Pending'),
        _buildCategoryButton('accepted', 'Accepted'),
      ],
    );
  }

  /// Single category button with full-width style
  Widget _buildCategoryButton(String category, String label) {
    final isSelected = selectedCategory == category;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedCategory = category;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceVariant,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
