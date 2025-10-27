import 'package:armstrong/models/timeslot/timeslot.dart';
import 'package:armstrong/services/api.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_new_bloc.dart';
import 'package:armstrong/config/global_loader.dart';

class RescheduleAppointmentForm extends StatefulWidget {
  final String appointmentId;
  final String specialistId;
  final VoidCallback? onRescheduled;

  const RescheduleAppointmentForm({
    Key? key,
    required this.appointmentId,
    required this.specialistId,
    this.onRescheduled,
  }) : super(key: key);

  @override
  _RescheduleAppointmentFormState createState() =>
      _RescheduleAppointmentFormState();
}

class _RescheduleAppointmentFormState extends State<RescheduleAppointmentForm> {
  final _storage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeSlotModel? _selectedTimeSlot;

  void _submitReschedule(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null || _selectedTimeSlot == null) {
        _showSnackBar("Missing Info", "Please select a date and time slot.", ContentType.warning);
        return;
      }

      final token = await _storage.read(key: 'token');
      final userType = await _storage.read(key: 'userType');

      if (token == null || userType == null) {
        _showSnackBar("Error", "User not authenticated.", ContentType.failure);
        return;
      }

      try {
        final api = ApiRepository();
        await api.rescheduleAppointment(
          widget.appointmentId,
          _selectedTimeSlot!.id,
          _selectedDate!,
          userType.toLowerCase(),
        );

        _showSnackBar(
          "Success",
          "Appointment successfully rescheduled!",
          ContentType.success,
        );

        Future.delayed(const Duration(milliseconds: 800), () {
          Navigator.of(context).pop();
          widget.onRescheduled?.call();
        });
      } catch (e) {
        _showSnackBar("Error", e.toString(), ContentType.failure);
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<TimeSlotBloc, TimeSlotState>(
      listener: (context, state) {
        if (state is TimeSlotFailure) {
          _showSnackBar("Error", state.error, ContentType.failure);
        }
      },
      child: AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(
          'Reschedule Appointment',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
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
            onPressed: () => _submitReschedule(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Confirm',
              style: TextStyle(color: colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return ListTile(
      leading: Icon(Icons.calendar_today,
          color: Theme.of(context).colorScheme.primary),
      title: Text(
        _selectedDate == null
            ? 'Select New Date'
            : 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
      ),
      onTap: () async {
        final DateTime now = DateTime.now();
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: now.add(const Duration(days: 1)),
          firstDate: now.add(const Duration(days: 1)),
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
          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        ),
      );
    }

    return BlocBuilder<TimeSlotBloc, TimeSlotState>(
      builder: (context, state) {
        if (state is TimeSlotLoading) {
          return GlobalLoader.loader;
        } else if (state is TimeSlotSuccess &&
            state.data is List<TimeSlotModel>) {
          final slots = state.data as List<TimeSlotModel>;
          if (slots.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                "No available slots for this date.",
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            );
          }

          return DropdownButtonFormField<TimeSlotModel>(
            value: _selectedTimeSlot,
            items: slots.map((slot) {
              return DropdownMenuItem<TimeSlotModel>(
                value: slot,
                child: Text("${slot.startTime} - ${slot.endTime}"),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedTimeSlot = value);
            },
            decoration: InputDecoration(
              labelText: 'Select New Time Slot',
              prefixIcon: Icon(Icons.access_time,
                  color: Theme.of(context).colorScheme.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) =>
                value == null ? 'Please select a time slot' : null,
          );
        } else if (state is TimeSlotFailure) {
          return Text(
            state.error,
            style: const TextStyle(color: Colors.redAccent),
          );
        }

        return Container();
      },
    );
  }
}
