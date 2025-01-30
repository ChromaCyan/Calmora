import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_bloc.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_event.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/config/colors.dart'; // Assuming you have a color configuration file

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
  TimeOfDay? _selectedTime;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null || _selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a date and time.'),
          ),
        );
        return;
      }

      final token = await _storage.read(key: 'token');
      final patientId = await _storage.read(key: 'userId');

      if (token != null && patientId != null) {
        final startTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );

        context.read<AppointmentBloc>().add(
              BookAppointmentEvent(
                patientId: patientId,
                specialistId: widget.specialistId,
                startTime: startTime,
                message: _messageController.text,
              ),
            );

        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text(
        'Book Appointment',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Date Picker
            ListTile(
              leading: Icon(
                Icons.calendar_today,
                color: orangeContainer,
              ),
              title: Text(
                _selectedDate == null
                    ? 'Select Date'
                    : 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                style: TextStyle(color: Colors.black87),
              ),
              onTap: () => _selectDate(context),
            ),
            // Time Picker
            ListTile(
              leading: Icon(
                Icons.access_time,
                color: orangeContainer,
              ),
              title: Text(
                _selectedTime == null
                    ? 'Select Time'
                    : 'Time: ${_selectedTime!.format(context)}',
                style: TextStyle(color: Colors.black87),
              ),
              onTap: () => _selectTime(context),
            ),
            // Message Input
            TextFormField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Message (Optional)',
                labelStyle: TextStyle(color: Colors.black54),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: orangeContainer),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextButton(
          onPressed: () => _submitForm(context),
          child: Text(
            'Confirm',
            style: TextStyle(
              color: orangeContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
