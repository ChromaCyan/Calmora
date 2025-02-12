import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:armstrong/widgets/cards/specialist_appointment_card.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:armstrong/services/api.dart'; 

class SpecialistAppointmentListScreen extends StatefulWidget {
  final String specialistId;

  const SpecialistAppointmentListScreen({required this.specialistId, Key? key}) : super(key: key);

  @override
  _SpecialistAppointmentListScreenState createState() =>
      _SpecialistAppointmentListScreenState();
}

class _SpecialistAppointmentListScreenState
    extends State<SpecialistAppointmentListScreen> {
  String selectedCategory = 'upcoming';
  List<dynamic> appointments = [];
  bool isLoading = true;
  String errorMessage = '';
  final ApiRepository _apiRepository = ApiRepository();

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    try {
      final fetchedAppointments =
          await _apiRepository.getSpecialistAppointments(widget.specialistId);
      setState(() {
        appointments = fetchedAppointments;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text('Error: $errorMessage'))
              : Column(
                  children: [
                    const SizedBox(height: 10),
                    _buildCategorySelector(),
                    Expanded(
                      child: _buildAppointmentList(),
                    ),
                  ],
                ),
    );
  }

  Widget _buildCategorySelector() {
    return Row(
      children: [
        _buildCategoryButton('upcoming', 'Upcoming'),
        _buildCategoryButton('pending', 'Pending'),
        _buildCategoryButton('accepted', 'Accepted'),
      ],
    );
  }

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
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceVariant,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade600, // Border color
            width: 1, // Border thickness
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    ),
  );
}


  Widget _buildAppointmentList() {
    List<dynamic> filteredAppointments = [];
    
    if (selectedCategory == 'upcoming') {
      // Find the closest accepted appointment to the current date and time
      var now = DateTime.now();
      var closestAccepted = appointments
          .where((appointment) => appointment['status'] == 'accepted')
          .map((appointment) {
            var appointmentTime = DateTime.parse(appointment['startTime']);
            var difference = appointmentTime.isBefore(now)
                ? Duration.zero
                : appointmentTime.difference(now);
            return {
              'appointment': appointment,
              'difference': difference,
            };
          })
          .toList();

      closestAccepted.sort((a, b) => a['difference'].compareTo(b['difference']));

      if (closestAccepted.isNotEmpty) {
        filteredAppointments.add(closestAccepted.first['appointment']);
      }
    } else if (selectedCategory == 'pending') {
      filteredAppointments = appointments
          .where((appointment) => appointment['status'] == 'pending')
          .toList();
    } else if (selectedCategory == 'accepted') {
      filteredAppointments = appointments
          .where((appointment) => appointment['status'] == 'accepted')
          .toList();
    }

    if (filteredAppointments.isEmpty) {
      return const Center(child: Text('No appointments available.'));
    }

    return ListView.builder(
      itemCount: filteredAppointments.length,
      itemBuilder: (context, index) {
        final appointment = filteredAppointments[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SpecialistAppointmentCard(
            appointment: appointment,
            onStatusChanged: _fetchAppointments, 
          ),
        );
      },
    );
  }
}
