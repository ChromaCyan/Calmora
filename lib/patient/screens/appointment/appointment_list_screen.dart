import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date and time formatting
import 'package:armstrong/services/api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppointmentListScreen extends StatefulWidget {
  final String patientId;

  const AppointmentListScreen({required this.patientId, Key? key})
      : super(key: key);

  @override
  _AppointmentListScreenState createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  final ApiRepository _apiRepository = ApiRepository();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  List<dynamic> _appointments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    final token = await _storage.read(key: 'token');
    if (token != null) {
      try {
        final appointments =
            await _apiRepository.getPatientAppointments(widget.patientId);
        if (mounted) {
          setState(() {
            _appointments = appointments;
            _isLoading = false;
          });
        }
      } catch (e) {
        print("Error loading appointments: $e");
        if (mounted) {
          setState(() {
            _error = e.toString();
            _isLoading = false;
          });
        }
      }
    }
  }

  // Format date and time
  String _formatDateTime(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    return DateFormat('MMM d, y h:mm a')
        .format(dateTime); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _appointments.isEmpty
                  ? Center(child: Text('No appointments found.'))
                  : ListView.builder(
                      itemCount: _appointments.length,
                      itemBuilder: (context, index) {
                        final appointment = _appointments[index];
                        final specialist = appointment['specialist'];
                        final specialistName =
                            '${specialist['firstName']} ${specialist['lastName']}';
                        final startTime =
                            _formatDateTime(appointment['startTime']);
                        final endTime = _formatDateTime(appointment['endTime']);
                        final status = appointment['status'];

                        return Card(
                          margin: EdgeInsets.all(8.0),
                          elevation: 4.0,
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  specialistName,
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  'Start: $startTime',
                                  style: TextStyle(fontSize: 16.0),
                                ),
                                Text(
                                  'End: $endTime',
                                  style: TextStyle(fontSize: 16.0),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  'Status: $status',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: status == 'pending'
                                        ? Colors.orange
                                        : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
