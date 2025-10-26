import 'package:armstrong/models/timeslot/timeslot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_new_bloc.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:intl/intl.dart';
import 'package:armstrong/config/global_loader.dart';

class AppointmentBookingForm extends StatefulWidget {
  final String specialistId;
  final VoidCallback? onBooked;

  const AppointmentBookingForm(
      {Key? key, required this.specialistId, this.onBooked})
      : super(key: key);

  @override
  _AppointmentBookingFormState createState() => _AppointmentBookingFormState();
}

class _AppointmentBookingFormState extends State<AppointmentBookingForm> {
  final _storage = FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  DateTime? _selectedDate;
  TimeSlotModel? _selectedTimeSlot;

  void _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null || _selectedTimeSlot == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a date and time.')),
        );
        return;
      }

      final token = await _storage.read(key: 'token');
      final patientId = await _storage.read(key: 'userId');

      if (token != null && patientId != null) {
        final DateTime slotTime =
            DateFormat('h:mm a').parse(_selectedTimeSlot!.startTime);

        final DateTime utcStartTime = DateTime.utc(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          slotTime.hour,
          slotTime.minute,
        );

        context.read<TimeSlotBloc>().add(
              BookAppointmentEvent(
                patientId: patientId,
                slotId: _selectedTimeSlot!.id,
                message: _messageController.text,
                appointmentDate: _selectedDate!,
              ),
            );
      } else {
        _showSnackBar(
          "Error",
          "User not authenticated.",
          ContentType.failure,
        );
      }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<TimeSlotBloc, TimeSlotState>(
      listener: (context, state) {
        if (state is TimeSlotSuccess) {
          if (state.data is Map<String, dynamic>) {
            // ✅ Booking success
            _showSnackBar(
              "Success",
              "Appointment successfully booked!",
              ContentType.success,
            );

            Future.delayed(const Duration(milliseconds: 800), () {
              Navigator.of(context).pop(); 
              widget.onBooked?.call(); 
            });

            // Optionally clear form fields
            setState(() {
              _selectedDate = null;
              _selectedTimeSlot = null;
              _messageController.clear();
            });
          } else {
            _showSnackBar(
              "Slots Loaded",
              "Available slots have been loaded.",
              ContentType.help,
            );
          }
        } else if (state is TimeSlotFailure) {
          // ❌ Booking or slot loading failed
          _showSnackBar(
            "Error",
            state.error,
            ContentType.failure,
          );
        } else if (state is TimeSlotLoading) {
          // ⏳ Fetching slots or booking
          _showSnackBar(
            "Loading",
            "Please wait while we process your request.",
            ContentType.warning,
          );
        }
      },
      child: AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(
          'Book Appointment',
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDatePicker(),
              _buildTimeSlotDropdown(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: colorScheme.error)),
          ),
          ElevatedButton(
            onPressed: () => _submitForm(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child:
                Text('Confirm', style: TextStyle(color: colorScheme.onPrimary)),
          ),
        ],
      ),
    );
  }

  // Widget _buildDatePicker() {
  //   return ListTile(
  //     leading: Icon(Icons.calendar_today,
  //         color: Theme.of(context).colorScheme.primary),
  //     title: Text(
  //       _selectedDate == null
  //           ? 'Select Date'
  //           : 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
  //       style: Theme.of(context).textTheme.bodyMedium,
  //     ),
  //     onTap: () async {
  //       DateTime? pickedDate = await showDatePicker(
  //         context: context,
  //         initialDate: DateTime.now(),
  //         firstDate: DateTime.now(),
  //         lastDate: DateTime(2101),
  //       );
  //       if (pickedDate != null) {
  //         setState(() {
  //           _selectedDate = pickedDate;
  //           _selectedTimeSlot = null;
  //         });
  //         context.read<TimeSlotBloc>().add(
  //               GetAvailableSlotsEvent(
  //                 specialistId: widget.specialistId,
  //                 date: _selectedDate!,
  //               ),
  //             );
  //       }
  //     },
  //   );
  // }
  Widget _buildDatePicker() {
    return ListTile(
      leading: Icon(Icons.calendar_today,
          color: Theme.of(context).colorScheme.primary),
      title: Text(
        _selectedDate == null
            ? 'Select Date'
            : 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      onTap: () async {
        DateTime now = DateTime.now();

        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: now.add(Duration(days: 1)),
          firstDate: now.add(Duration(days: 1)),
          lastDate: DateTime(2101),
        );

        if (pickedDate != null) {
          setState(() {
            _selectedDate = pickedDate;
            _selectedTimeSlot = null;
          });

          context.read<TimeSlotBloc>().add(
                GetAvailableSlotsEvent(
                  specialistId: widget.specialistId,
                  date: _selectedDate!,
                ),
              );
        }
      },
    );
  }

  Widget _buildTimeSlotDropdown() {
    if (_selectedDate == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          "Please select a date first.",
          style: TextStyle(
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return BlocBuilder<TimeSlotBloc, TimeSlotState>(
      builder: (context, state) {
        if (state is TimeSlotLoading) {
          return GlobalLoader.loader;
        } else if (state is TimeSlotSuccess &&
            state.data is List<TimeSlotModel>) {
          final List<TimeSlotModel> availableSlots = state.data;

          if (availableSlots.isEmpty) {
            _selectedTimeSlot = null;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                "No available slots for this specialist.",
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          }

          return DropdownButtonFormField<TimeSlotModel>(
            value: _selectedTimeSlot,
            items: availableSlots.map((TimeSlotModel slot) {
              String formattedTime = DateFormat('hh:mm a').format(
                DateFormat('h:mm a').parse(slot.startTime),
              );
              return DropdownMenuItem<TimeSlotModel>(
                value: slot,
                child: Text(formattedTime),
              );
            }).toList(),
            onChanged: (TimeSlotModel? value) {
              setState(() {
                _selectedTimeSlot = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'Select Time Slot',
              prefixIcon: Icon(
                Icons.access_time,
                color: Theme.of(context).colorScheme.primary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) =>
                value == null ? 'Please select a time slot' : null,
          );
        } else if (state is TimeSlotFailure) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                state.error,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          );
        }

        return Container();
      },
    );
  }
}
