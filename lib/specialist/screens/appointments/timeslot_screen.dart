import 'package:armstrong/models/timeslot/timeslot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_new_bloc.dart';
import 'package:armstrong/widgets/forms/timeslot_form.dart';
import 'package:intl/intl.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:armstrong/config/global_loader.dart';

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

  // void _navigateToAddSlot() async {
  //   final result = await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => TimeSlotForm(specialistId: widget.specialistId),
  //     ),
  //   );

  //   if (result == true) {
  //     _fetchTimeSlots();
  //   }
  // }
  void _navigateToAddSlot() async {
  final result = await Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          TimeSlotForm(specialistId: widget.specialistId),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(1.0, 0.0), 
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        );
        return SlideTransition(position: slideAnimation, child: child);
      },
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
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(35),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              const Padding(
                padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 8),
                child: Text(
                  'Delete Time Slot?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Message
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Text(
                  'Are you sure you want to delete this time slot?',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const Divider(height: 20, thickness: 0.5),

              // Action buttons
              Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20)),
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Vertical divider between buttons
                  Container(
                    width: 0.5,
                    height: 44,
                    color: Colors.grey.withOpacity(0.4),
                  ),

                  // Delete button
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.only(bottomRight: Radius.circular(20)),
                      splashColor: Colors.red.shade700.withOpacity(0.2),
                      onTap: () {
                        Navigator.pop(context);
                        _deleteSlot(slotId);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

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
        child: Stack(
          children: [
            Column(
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
                          return GlobalLoader.loader;
                        } else if (state is TimeSlotSuccess) {
                          final slots = state.data as List<TimeSlotModel>;

                          if (slots.isEmpty) {
                            return RefreshIndicator(
                              onRefresh: () async => _fetchTimeSlots(),
                              child: ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: const [
                                  SizedBox(height: 200),
                                  Center(
                                    child: Text(
                                      "No available time slots. Please add new slots.",
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          // Group by day
                          Map<String, List<TimeSlotModel>> grouped = {};
                          for (var slot in slots) {
                            grouped
                                .putIfAbsent(slot.dayOfWeek, () => [])
                                .add(slot);
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

                          return RefreshIndicator(
                            onRefresh: () async => _fetchTimeSlots(),
                            child: ListView(
                              padding: const EdgeInsets.only(bottom: 90),
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                for (var day in daysOfWeek)
                                  if (grouped.containsKey(day) &&
                                      grouped[day]!.isNotEmpty) ...[
                                    Text(
                                      day,
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
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
                            ),
                          );
                        } else if (state is TimeSlotFailure) {
                          return RefreshIndicator(
                            onRefresh: () async => _fetchTimeSlots(),
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(height: 200),
                                Center(
                                  child: Text(
                                    "Something went wrong. Pull down to retry.",
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.error),
                                  ),
                                ),
                              ],
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
              ],
            ),

            // Floating Add Slot Button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Center(
                child: FloatingActionButton(
                  elevation: 0,
                  onPressed: _navigateToAddSlot,
                  backgroundColor: theme.colorScheme.primary,
                  mini: true,
                  child: Icon(
                    Icons.add, 
                    size: 30,
                    color: theme.colorScheme.surface,),
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
    final theme = Theme.of(context);
    String formatTime(String time) {
      final parsed = DateFormat("HH:mm").parse(time);
      return DateFormat("h:mm a").format(parsed);
    }

    final formattedTime =
        "${formatTime(slot.startTime)} - ${formatTime(slot.endTime)}";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(25),
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
              icon: Icon(Icons.edit, size: 22,),
              onPressed: () => _navigateToEditSlot(slot),
            ),
            IconButton(
              icon: Icon(Icons.delete, size: 22, color: Colors.red.shade700,),
              onPressed: () => _confirmDeleteSlot(slot.id),
            ),
          ],
        ),
      ),
    );
  }
}
