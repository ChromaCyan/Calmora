import 'package:flutter/material.dart';
import 'package:armstrong/services/api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:armstrong/widgets/cards/appointment_complete_pop_card.dart';

class CompletedAppointmentsScreen extends StatefulWidget {
  const CompletedAppointmentsScreen({super.key});

  @override
  _CompletedAppointmentsScreenState createState() =>
      _CompletedAppointmentsScreenState();
}

class _CompletedAppointmentsScreenState
    extends State<CompletedAppointmentsScreen> {
  final ApiRepository _apiRepository = ApiRepository();
  List<dynamic> completedAppointments = [];
  bool isLoading = true;
  bool hasError = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    final userId = await storage.read(key: 'userId');

    if (userId != null) {
      setState(() {
        _userId = userId;
      });
      _fetchCompletedAppointments();
    } else {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  Future<void> _fetchCompletedAppointments() async {
    if (_userId == null) return;

    try {
      final response = await _apiRepository.getCompletedAppointments(_userId!);
      setState(() {
        completedAppointments = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) return "N/A";
    final dateTime = DateTime.parse(dateTimeString);
    return DateFormat("MMM dd, yyyy - hh:mm a").format(dateTime);
  }

  void _showAppointmentDetails(BuildContext context, dynamic appointment) {
    showDialog(
      context: context,
      builder: (context) {
        return AppointmentDetailsDialog(appointment: appointment);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Completed Appointments")),
      body: completedAppointments.isEmpty
          ? const Center(child: Text("No completed appointments"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: completedAppointments.length,
              itemBuilder: (context, index) {
                final appointment = completedAppointments[index];
                return GestureDetector(
                  onTap: () => _showAppointmentDetails(context, appointment),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(Icons.check_circle,
                          color: Colors.green, size: 32),
                      title: Text(
                        "With: ${appointment["specialist"]?["firstName"] ?? "Unknown"}",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Row(
                        children: [
                          const Icon(Icons.access_time, size: 18),
                          const SizedBox(width: 6),
                          Text(_formatDateTime(appointment["startTime"]))
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
