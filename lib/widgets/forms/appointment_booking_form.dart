import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_bloc.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_event.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_state.dart';
import 'package:intl/intl.dart';

class AppointmentBookingForm extends StatefulWidget {
  final String specialistId;

  const AppointmentBookingForm({Key? key, required this.specialistId})
      : super(key: key);

  @override
  _AppointmentBookingFormState createState() => _AppointmentBookingFormState();
}

class _AppointmentBookingFormState extends State<AppointmentBookingForm> {
  final _storage = FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  DateTime? _selectedDate;
  DateTime? _selectedTimeSlot;

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
        final DateTime utcStartTime = DateTime.utc(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTimeSlot!.hour,
          _selectedTimeSlot!.minute,
        );

        String formattedStartTime = utcStartTime.toIso8601String();

        context.read<AppointmentBloc>().add(
              BookAppointmentEvent(
                patientId: patientId,
                specialistId: widget.specialistId,
                startTime: utcStartTime,
                message: _messageController.text,
              ),
            );

        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      title: Text(
        'Book Appointment',
        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text('Confirm', style: TextStyle(color: colorScheme.onPrimary)),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return ListTile(
      leading: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
      title: Text(
        _selectedDate == null
            ? 'Select Date'
            : 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          setState(() {
            _selectedDate = pickedDate;
            _selectedTimeSlot = null; // Reset the selected time slot
          });
          context.read<AppointmentBloc>().add(
                FetchAvailableTimeSlotsEvent(
                  specialistId: widget.specialistId,
                  date: _selectedDate!,
                ),
              );
        }
      },
    );
  }

  Widget _buildTimeSlotDropdown() {
    return BlocBuilder<AppointmentBloc, AppointmentState>(
      builder: (context, state) {
        if (state is AppointmentLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is AvailableTimeSlotsLoaded) {
          final List<DateTime> availableSlots = state.availableSlots;

          if (availableSlots.isEmpty) {
            _selectedTimeSlot = null; // Reset the time slot when there are no available slots
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

          return DropdownButtonFormField<DateTime>(
            value: _selectedTimeSlot, // Store DateTime directly
            items: availableSlots.map((DateTime slot) {
              String formattedTime = DateFormat('hh:mm a').format(slot); // 12-hour format

              return DropdownMenuItem<DateTime>(
                value: slot,
                child: Text(formattedTime),
              );
            }).toList(),
            onChanged: (DateTime? value) {
              setState(() {
                _selectedTimeSlot = value; // Store DateTime object
              });
            },
            decoration: InputDecoration(
              labelText: 'Select Time Slot',
              prefixIcon: Icon(
                Icons.access_time,
                color: Theme.of(context).colorScheme.primary,
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            validator: (value) =>
                value == null ? 'Please select a time slot' : null,
          );
        } else if (state is AppointmentError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              "Specialist has not set working hours yet.",
              style: TextStyle(color: Colors.red),
            ),
          );
        }
        return Container(); 
      },
    );
  }
}