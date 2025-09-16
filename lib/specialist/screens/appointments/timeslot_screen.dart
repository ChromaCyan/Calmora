import 'package:armstrong/models/timeslot/timeslot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_new_bloc.dart';
import 'package:armstrong/widgets/forms/timeslot_form.dart';
import 'package:intl/intl.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class TimeSlotListScreen extends StatefulWidget {
  final String specialistId;

  const TimeSlotListScreen({Key? key, required this.specialistId})
      : super(key: key);

  @override
  _TimeSlotListScreenState createState() => _TimeSlotListScreenState();
}

class _TimeSlotListScreenState extends State<TimeSlotListScreen> {
  bool hasFetched = false;
  @override
  void initState() {
    super.initState();
    if (!hasFetched) {
      _fetchTimeSlots();
      hasFetched = true;
    }
  }

  void _fetchTimeSlots() {
    context.read<TimeSlotBloc>().add(
          GetAllSlotsEvent(
            specialistId: widget.specialistId,
          ),
        );
  }

  void _navigateToAddSlot() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimeSlotForm(specialistId: widget.specialistId),
      ),
    );

    if (result == true) {
      _fetchTimeSlots();
    }
  }

  void _showSnackBar(String title, String message, ContentType type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: title,
          message: message,
          contentType: type,
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _navigateToEditSlot(TimeSlotModel slot) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimeSlotForm(
          slotId: slot.id,
          specialistId: widget.specialistId,
          initialDayOfWeek: slot.dayOfWeek,
          initialStartTime: slot.startTime,
          initialEndTime: slot.endTime,
        ),
      ),
    );

    if (result == true) {
      _fetchTimeSlots();
    }
  }

  // ✅ Confirm and delete slot
  void _confirmDeleteSlot(String slotId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Time Slot"),
        content: const Text("Are you sure you want to delete this time slot?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSlot(slotId);
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Delete slot using Bloc
  void _deleteSlot(String slotId) {
    context.read<TimeSlotBloc>().add(
          DeleteTimeSlotEvent(
            slotId: slotId,
            specialistId: widget.specialistId,
          ),
        );
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
        child: Column(
          children: [
            Expanded(
              child: MultiBlocListener(
                listeners: [
                  BlocListener<TimeSlotBloc, TimeSlotState>(
                    listener: (context, state) {
                      if (state is TimeSlotDeleted) {
                        _showSnackBar(
                          "Success",
                          "Time slot deleted successfully.",
                          ContentType.success,
                        );
                        _fetchTimeSlots();
                      } else if (state is TimeSlotFailure &&
                          !state.error.contains("No time slots found")) {
                        _showSnackBar(
                          "Error",
                          state.error.contains(
                                  "Cannot delete a slot with upcoming appointments")
                              ? "Cannot delete a slot that has upcoming appointments."
                              : "Error: ${state.error}",
                          ContentType.failure,
                        );
                      }
                    },
                  ),
                ],
                child: BlocBuilder<TimeSlotBloc, TimeSlotState>(
                  builder: (context, state) {
                    if (state is TimeSlotLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is TimeSlotSuccess) {
                      final slots = state.data as List<TimeSlotModel>;

                      if (slots.isEmpty) {
                        return const Center(
                          child: Text(
                            "No available time slots. Please add new slots.",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        );
                      }

                      // group by day
                      Map<String, List<TimeSlotModel>> grouped = {};
                      for (var slot in slots) {
                        grouped.putIfAbsent(slot.dayOfWeek, () => []).add(slot);
                      }

                      final daysOfWeek = [
                        "Monday",
                        "Tuesday",
                        "Wednesday",
                        "Thursday",
                        "Friday",
                        "Saturday",
                        "Sunday"
                      ];

                      return ListView(
                        physics: const BouncingScrollPhysics(),
                        children: [
                          for (var day in daysOfWeek)
                            if (grouped.containsKey(day) &&
                                grouped[day]!.isNotEmpty) ...[
                              Text(
                                day,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onBackground,
                                ),
                              ),
                              const SizedBox(height: 8),
                              for (var slot in grouped[day]!) ...[
                                _buildSlotTile(slot),
                                const SizedBox(height: 12),
                              ],
                              const SizedBox(height: 16),
                            ],
                        ],
                      );
                    } else if (state is TimeSlotFailure) {
                      if (state.error.contains("No time slots found")) {
                        return const Center(
                          child: Text(
                            "No available time slots. Please add new slots.",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        );
                      }
                      return Center(
                        child: Text(
                          "Error loading time slots. Please try again later.",
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: theme.colorScheme.error),
                        ),
                      );
                    } else {
                      return const Center(
                          child: Text("No time slots available."));
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Add Slot Button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _navigateToAddSlot,
                label: const Text("Add Slot"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Sample helper for building slot tile
  Widget _buildSlotTile(TimeSlotModel slot) {
    String formatTime(String time) {
      final parsed = DateFormat("HH:mm").parse(time);
      return DateFormat("h:mm a").format(parsed);
    }

    final formattedTime =
        "${formatTime(slot.startTime)} - ${formatTime(slot.endTime)}";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          formattedTime,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 22),
              onPressed: () => _navigateToEditSlot(slot),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 22),
              onPressed: () => _confirmDeleteSlot(slot.id),
            ),
          ],
        ),
      ),
    );
  }
}
