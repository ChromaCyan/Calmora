import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_new_bloc.dart';
import 'package:armstrong/widgets/navigation/appbar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:intl/intl.dart';

class TimeSlotForm extends StatefulWidget {
  final String? slotId;
  final String specialistId;
  final String? initialDayOfWeek;
  final String? initialStartTime;
  final String? initialEndTime;

  const TimeSlotForm({
    Key? key,
    this.slotId,
    required this.specialistId,
    this.initialDayOfWeek,
    this.initialStartTime,
    this.initialEndTime,
  }) : super(key: key);

  @override
  _TimeSlotPageState createState() => _TimeSlotPageState();
}

class _TimeSlotPageState extends State<TimeSlotForm> {
  String? _selectedDay;
  String? _startTime;
  String? _endTime;

  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    if (widget.slotId != null) {
      _selectedDay = widget.initialDayOfWeek;
      _startTime = convertTo12HourFormat(widget.initialStartTime);
      _endTime = convertTo12HourFormat(widget.initialEndTime);
    }
  }

  String _getFriendlyErrorMessage(String error) {
    if (error.contains("overlaps with existing slot")) {
      return "This time slot overlaps with another. Please choose a different time.";
    } else if (error.contains("already exists")) {
      return "A time slot for this day already exists. Edit the existing one.";
    } else {
      return "An unexpected error occurred. Please try again.";
    }
  }

  String convertTo12HourFormat(String? time) {
    if (time == null || time.isEmpty) return "";
    final parsedTime = DateFormat("HH:mm").parse(time);
    return DateFormat("h:mm a").format(parsedTime);
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

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final String updatedDay = _selectedDay ?? widget.initialDayOfWeek!;
      final String updatedStartTime = _startTime ?? widget.initialStartTime!;
      final String updatedEndTime = _endTime ?? widget.initialEndTime!;

      if (widget.slotId == null) {
        // Create new time slot
        context.read<TimeSlotBloc>().add(
              CreateTimeSlotEvent(
                specialistId: widget.specialistId,
                dayOfWeek: updatedDay,
                startTime: updatedStartTime,
                endTime: updatedEndTime,
              ),
            );
      } else {
        // Update existing time slot
        context.read<TimeSlotBloc>().add(
              UpdateTimeSlotEvent(
                slotId: widget.slotId!,
                dayOfWeek: updatedDay,
                startTime: updatedStartTime,
                endTime: updatedEndTime,
                specialistId: widget.specialistId,
              ),
            );
      }
    } else {
      _showSnackBar(
        'Form Error',
        'Please fill out all fields correctly!',
        ContentType.warning,
      );
    }
  }

  Future<void> _navigateBack(BuildContext context) async {
    Navigator.pop(context, true);
    context.read<TimeSlotBloc>().add(ResetTimeSlotEvent());
  }

  void _clearForm() {
  setState(() {
    _selectedDay = null;
    _startTime = null;
    _endTime = null;
  });

  _formKey.currentState?.reset();
}


  Widget _buildDropdown(String label, List<String> items, String? value,
      Function(String?) onChanged) {
    final theme = Theme.of(context);
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: theme.colorScheme.surface.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
      ),
      dropdownColor: theme.colorScheme.surface.withOpacity(0.9), 
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select a day' : null,
    );
  }

  Widget _buildTimeField(String label, String? value, Function(String) onSaved,
      {bool isStartTime = true}) {
    final theme = Theme.of(context);
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(text: value),
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.access_time),
        filled: true,
        fillColor: theme.colorScheme.surface.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
      ),
      onTap: () async {
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (pickedTime != null) {
          final String formattedTime = pickedTime.format(context);
          onSaved(formattedTime);
        }
      },
      validator: (value) =>
          (value == null || value.isEmpty) ? 'Please select a time' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      // appBar: UniversalAppBar(
      //   title: widget.slotId == null ? 'Add Time Slot' : 'Edit Time Slot',
      //   onBackPressed: () => _navigateBack(context),
      // ),
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
            child: Container(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          onPressed: () async {
            Navigator.pop(context);
          },
        ),
        title: Text(widget.slotId == null ? "Add Time Slot" : "Edit Time Slot", style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocListener<TimeSlotBloc, TimeSlotState>(
        listener: (context, state) {
          if (state is TimeSlotSuccess) {
            _showSnackBar(
              'Success!',
              widget.slotId == null
                  ? 'Time slot created successfully!'
                  : 'Time slot updated successfully!',
              ContentType.success,
            );
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.pop(context, true);
            });
          } else if (state is TimeSlotFailure) {
            _showSnackBar(
              'Error!',
              _getFriendlyErrorMessage(state.error),
              ContentType.failure,
            );
          }
        },

        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              "images/login_bg_image.png",
              fit: BoxFit.fill,
            ),
            Container(
              color: theme.colorScheme.surface.withOpacity(0.6),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: const SizedBox.expand(),
              ),
            ),
            Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const SizedBox(height: 30),
    // Removed Expanded and Center — we’ll directly use Padding and Form at the top
    Padding(
      padding: const EdgeInsets.all(21.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select which day will you be available.",
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 15,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 10),

              // Day of the week dropdown
              _buildDropdown(
                'Select Day',
                _daysOfWeek,
                _selectedDay,
                (value) => setState(() => _selectedDay = value),
              ),

              const SizedBox(height: 25),

              Text(
                "What time will you be available?",
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 15,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 10),

              // Start time
              _buildTimeField(
                'Start Time',
                _startTime,
                (value) => setState(() => _startTime = value),
              ),

              const SizedBox(height: 25),

              Text(
                "What time will you no longer be available?",
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 15,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 10),

              // End time
              _buildTimeField(
                'End Time',
                _endTime,
                (value) => setState(() => _endTime = value),
              ),

              const SizedBox(height: 75),

              // Buttons row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _clearForm,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(18)),
                      ),
                      side: BorderSide(
                        color: Colors.grey.shade500,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      'Clear Time Slot',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(18)),
                      ),
                    ),
                    child: Text(
                      widget.slotId == null ? 'Save Time Slot' : 'Update Time Slot',
                      style: TextStyle(
                        color: theme.colorScheme.surface,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  ],
)
          ],
        ),
      ),
    );
  }
}
