import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_bloc.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_event.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_state.dart';
import 'package:armstrong/widgets/cards/appointment_card.dart';
import 'package:armstrong/config/global_loader.dart';

class AppointmentListScreen extends StatefulWidget {
  final String patientId;

  const AppointmentListScreen({required this.patientId, Key? key})
      : super(key: key);

  @override
  _AppointmentListScreenState createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  String selectedCategory = 'pending';

  Future<void> _refreshAppointments() async {
    context
        .read<AppointmentBloc>()
        .add(FetchPatientAppointmentsEvent(patientId: widget.patientId));
  }

  @override
  void initState() {
    super.initState();
    _refreshAppointments();
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
        child: BlocBuilder<AppointmentBloc, AppointmentState>(
          builder: (context, state) {
            if (state is AppointmentLoading) {
              return GlobalLoader.loader;
            } else if (state is AppointmentError) {
              return Column(
                children: [
                  _buildCategorySelector(theme),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Center(child: Text('Error: ${state.message}')),
                  ),
                ],
              );
            } else if (state is PatientAppointmentsLoaded) {
              final allAppointments = state.appointments
                  .where((appointment) => appointment['status'] != 'declined')
                  .toList();

              // Sort by appointment date
              allAppointments.sort((a, b) {
                final aTime = DateTime.parse(a['appointmentDate']);
                final bTime = DateTime.parse(b['appointmentDate']);
                return aTime.compareTo(bTime);
              });

              final pendingAppointments = allAppointments
                  .where((a) => a['status'] == 'pending')
                  .toList();
              final acceptedAppointments = allAppointments
                  .where((a) =>
                      a['status'] == 'accepted' || a['status'] == 'rescheduled')
                  .toList();

              final filteredAppointments = selectedCategory == 'pending'
                  ? pendingAppointments
                  : acceptedAppointments;

              return Column(
                children: [
                  _buildCategorySelector(theme),
                  const SizedBox(height: 10),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refreshAppointments,
                      child: filteredAppointments.isEmpty
                          ? ListView(
                              physics:
                                  const AlwaysScrollableScrollPhysics(), // ensures pull works
                              children: const [
                                SizedBox(height: 200),
                                Center(
                                    child: Text('No appointments available.')),
                              ],
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: filteredAppointments.length,
                              itemBuilder: (context, index) {
                                final appointment = filteredAppointments[index];
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: AppointmentCard(
                                    appointment: appointment,
                                    onUpdated: _refreshAppointments,
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                _buildCategorySelector(theme),
                const SizedBox(height: 10),
                const Expanded(
                  child: Center(child: Text('Unexpected state.')),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategorySelector(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildCategoryButton('pending', 'Pending', theme),
          _buildCategoryButton('accepted', 'Accepted', theme),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String category, String label, ThemeData theme) {
    final isSelected = selectedCategory == category;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedCategory = category),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
