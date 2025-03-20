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
  @override
  void initState() {
    super.initState();
    _fetchTimeSlots();
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
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          // ✅ Handle delete errors gracefully
          BlocListener<TimeSlotBloc, TimeSlotState>(
            listener: (context, state) {
              if (state is TimeSlotDeleted) {
                _showSnackBar(
                  "Success",
                  "Time slot deleted successfully.",
                  ContentType.success,
                );
                _fetchTimeSlots(); 
              } else if (state is TimeSlotFailure) {
                _showSnackBar(
                  "Error",
                  state.error.contains(
                          "Cannot delete a slot with upcoming appointments")
                      ? "Cannot delete a slot that has upcoming appointments."
                      : "Error: ${state.error}",
                  ContentType.failure,
                );
                _fetchTimeSlots(); 
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

              // Grouping slots by dayOfWeek
              Map<String, List<TimeSlotModel>> groupedSlots = {};
              for (var slot in slots) {
                if (!groupedSlots.containsKey(slot.dayOfWeek)) {
                  groupedSlots[slot.dayOfWeek] = [];
                }
                groupedSlots[slot.dayOfWeek]!.add(slot);
              }

              // Sorting days in the week
              final daysOfWeek = [
                "Monday",
                "Tuesday",
                "Wednesday",
                "Thursday",
                "Friday",
                "Saturday",
                "Sunday"
              ];

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: daysOfWeek.length,
                itemBuilder: (context, index) {
                  String day = daysOfWeek[index];
                  List<TimeSlotModel>? daySlots = groupedSlots[day];

                  if (daySlots == null || daySlots.isEmpty) {
                    return Container(); // Skip days with no slots
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...daySlots.map((slot) {
                        String formatTime(String time) {
                          final parsedTime = DateFormat("HH:mm").parse(time);
                          return DateFormat("h:mm a").format(parsedTime);
                        }

                        final formattedTime =
                            "${formatTime(slot.startTime)} - ${formatTime(slot.endTime)}";

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              formattedTime,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // ✏️ Edit Slot Icon
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () {
                                    _navigateToEditSlot(slot);
                                  },
                                ),
                                // ❌ Delete Slot Icon
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    _confirmDeleteSlot(slot.id);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              );
            } else if (state is TimeSlotFailure) {
              return const Center(
                child: Text(
                  "Error loading time slots. Please try again later.",
                  style: TextStyle(color: Colors.red),
                ),
              );
            }

            return const Center(child: Text("No time slots available."));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddSlot,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
