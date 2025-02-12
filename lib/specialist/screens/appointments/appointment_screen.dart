import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_bloc.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_state.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_event.dart';
import 'package:armstrong/widgets/cards/specialist_appointment_card.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

class SpecialistAppointmentListScreen extends StatefulWidget {
  final String specialistId;

  const SpecialistAppointmentListScreen({required this.specialistId, Key? key}) : super(key: key);

  @override
  _SpecialistAppointmentListScreenState createState() => _SpecialistAppointmentListScreenState();
}

class _SpecialistAppointmentListScreenState extends State<SpecialistAppointmentListScreen> {
  String selectedCategory = 'upcoming'; // Default category

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
            return const Center(child: CircularProgressIndicator());
          } else if (state is AppointmentError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is SpecialistAppointmentsLoaded) {
            final allAppointments = state.appointments
                .where((appointment) => appointment['status'] != 'declined')
                .toList();

            if (allAppointments.isEmpty) {
              return const Center(child: Text('No appointments found.'));
            }

            // Sort by nearest appointment
            allAppointments.sort((a, b) {
              final aTime = DateTime.parse(a['startTime']);
              final bTime = DateTime.parse(b['startTime']);
              return aTime.compareTo(bTime);
            });

            // Filter categories
            final upcomingAppointments = allAppointments.take(3).toList();
            final pendingAppointments = allAppointments.where((a) => a['status'] == 'pending').toList();
            final acceptedAppointments = allAppointments.where((a) => a['status'] == 'accepted').toList();

            // Select correct list based on category
            List filteredAppointments;
            if (selectedCategory == 'upcoming') {
              filteredAppointments = upcomingAppointments;
            } else if (selectedCategory == 'pending') {
              filteredAppointments = pendingAppointments;
            } else {
              filteredAppointments = acceptedAppointments;
            }

            return Column(
              children: [
                const SizedBox(height: 10),
                _buildCategorySelector(),
                Expanded(
                  child: filteredAppointments.isEmpty
                      ? const Center(child: Text('No appointments available.'))
                      : ListView.builder(
                          itemCount: filteredAppointments.length,
                          itemBuilder: (context, index) {
                            final appointment = filteredAppointments[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: SpecialistAppointmentCard(appointment: appointment),
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
        _buildCategoryButton('upcoming', 'Upcoming'),
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
          color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceVariant,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
