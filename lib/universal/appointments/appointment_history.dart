import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:armstrong/services/api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:armstrong/widgets/cards/appointment_complete_pop_card.dart';
import 'package:armstrong/config/global_loader.dart';

class CompletedAppointmentsScreen extends StatefulWidget {
  const CompletedAppointmentsScreen({super.key});

  @override
  _CompletedAppointmentsScreenState createState() =>
      _CompletedAppointmentsScreenState();
}

class _CompletedAppointmentsScreenState
    extends State<CompletedAppointmentsScreen> {
  final ApiRepository _apiRepository = ApiRepository();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  List<dynamic> completedAppointments = [];
  bool isLoading = true;
  bool hasError = false;
  String? _userId;
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _userId = await _storage.read(key: 'userId');
    _role = await _storage.read(key: 'userType');
    if (_userId != null) {
      await _fetchCompletedAppointments();
    } else {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> _fetchCompletedAppointments() async {
    try {
      if (_userId == null) return;
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

    final formattedDate = DateFormat("MMM dd, yyyy").format(appointmentDate);
    return "$formattedDate - $startTime to $endTime";
  }

  void _showAppointmentDetails(BuildContext context, dynamic appointment) {
    showDialog(
      context: context,
      builder: (context) {
        return AppointmentDetailsDialog(
          appointment: appointment,
          userRole: _role ?? 'Patient',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
            child: Container(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
            ),
          ),
        ),
        title: Text(
          "Completed Appointments",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "images/login_bg_image.png",
            fit: BoxFit.cover,
          ),
          Container(
            color: theme.colorScheme.surface.withOpacity(0.6),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: const SizedBox.expand(),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 10),
              Expanded(
                child: isLoading
                    ? Center(child: GlobalLoader.loader)
                    : hasError
                        ? Center(
                            child: Text(
                              "Failed to load completed appointments",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          )
                        : completedAppointments.isEmpty
                            ? Center(
                                child: Text(
                                  "No completed appointments",
                                  style: theme.textTheme.bodyMedium,
                                ),
                              )
                            : ListView.builder(
                                itemCount: completedAppointments.length,
                                itemBuilder: (context, index) {
                                  final appointment =
                                      completedAppointments[index];

                                  // Determine which user to display
                                  final isSpecialist =
                                      _role?.toLowerCase() == 'specialist';
                                  final displayUser = isSpecialist
                                      ? appointment["patient"]
                                      : appointment["specialist"];

                                  final fullName =
                                      "${displayUser?["firstName"] ?? "Unknown"} ${displayUser?["lastName"] ?? ""}".trim();
                                  final profileImage =
                                      displayUser?["profileImage"] ?? "";

                                  return GestureDetector(
                                    onTap: () => _showAppointmentDetails(
                                        context, appointment),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: theme.cardColor.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          if (theme.brightness ==
                                              Brightness.light)
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 25,
                                            backgroundImage:
                                                profileImage.isNotEmpty
                                                    ? NetworkImage(profileImage)
                                                    : const AssetImage(
                                                            "images/default_avatar.png")
                                                        as ImageProvider,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  fullName,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: theme.brightness ==
                                                            Brightness.light
                                                        ? Colors.black
                                                        : Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.calendar_today,
                                                      size: 16,
                                                      color: theme.brightness ==
                                                              Brightness.light
                                                          ? Colors.black54
                                                          : Colors.white70,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        _formatAppointmentTime(
                                                            appointment),
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: theme
                                                                      .brightness ==
                                                                  Brightness
                                                                      .light
                                                              ? Colors.black87
                                                              : Colors.white70,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
