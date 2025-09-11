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

  String _formatAppointmentTime(dynamic appointment) {
    if (appointment["appointmentDate"] == null ||
        appointment["timeSlot"] == null) {
      return "N/A";
    }

    final appointmentDate = DateTime.parse(appointment["appointmentDate"]);
    final startTime = appointment["timeSlot"]["startTime"];
    final endTime = appointment["timeSlot"]["endTime"];

    // Format the date and time range
    final formattedDate = DateFormat("MMM dd, yyyy").format(appointmentDate);
    return "$formattedDate - $startTime to $endTime";
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Completed Appointments",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: isDark ? 0 : 1,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[100],
      body: completedAppointments.isEmpty
          ? Center(
              child: Text(
                "No completed appointments",
                style:
                    TextStyle(color: isDark ? Colors.white70 : Colors.black87),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: completedAppointments.length,
              itemBuilder: (context, index) {
                final appointment = completedAppointments[index];
                final Color stripColor = Colors.green; // dynamic if needed

                return GestureDetector(
                  onTap: () => _showAppointmentDetails(context, appointment),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.3)
                            : Colors.black.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // thin colored strip on the left
                          Container(
                            width: 10, // slightly thinner
                            decoration: BoxDecoration(
                              color: stripColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                            ),
                          ),

                          // content
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'With: ${appointment["specialist"]?["firstName"] ?? "Unknown"}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today,
                                          size: 16,
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.black54),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          _formatAppointmentTime(appointment),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isDark
                                                ? Colors.white70
                                                : Colors.black54,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // trailing chevron
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 18,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
