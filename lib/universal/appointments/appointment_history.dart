import 'package:flutter/material.dart';
import 'package:armstrong/services/api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CompletedAppointmentsScreen extends StatefulWidget {
  const CompletedAppointmentsScreen({super.key});

  @override
  _CompletedAppointmentsScreenState createState() => _CompletedAppointmentsScreenState();
}

class _CompletedAppointmentsScreenState extends State<CompletedAppointmentsScreen> {
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
      _fetchCompletedAppointments(); // Fetch data after setting _userId
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
        completedAppointments = response; // Directly assign response (it's an array)
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Completed Appointments")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text("Failed to load appointments"))
              : completedAppointments.isEmpty
                  ? const Center(child: Text("No completed appointments"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: completedAppointments.length,
                      itemBuilder: (context, index) {
                        final appointment = completedAppointments[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(
                              "With: ${appointment["specialist"]?["firstName"] ?? appointment["patient"]?["firstName"] ?? "Unknown"}",
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Date: ${appointment["startTime"]?.split('T')[0] ?? "N/A"}"),
                                Text("Time: ${appointment["startTime"]?.split('T')[1].split('.')[0] ?? "N/A"}"),
                                Text("Status: Completed"),
                                if (appointment["feedback"] != null) Text("Feedback: ${appointment["feedback"]}"),
                              ],
                            ),
                            leading: const Icon(Icons.check_circle, color: Colors.green),
                          ),
                        );
                      },
                    ),
    );
  }
}
