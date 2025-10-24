import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentDetailsDialog extends StatelessWidget {
  final dynamic appointment;
  final String userRole;

  const AppointmentDetailsDialog({
    super.key,
    required this.appointment,
    required this.userRole,
  });

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

  @override
  Widget build(BuildContext context) {
    final isSpecialist = userRole.toLowerCase() == 'specialist';
    final displayUser =
        isSpecialist ? appointment["patient"] : appointment["specialist"];
    final displayName =
        "${displayUser?["firstName"] ?? "Unknown"} ${displayUser?["lastName"] ?? ""}".trim();

    return Stack(
      children: [
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Material(
              color: Theme.of(context).cardColor.withOpacity(0.6),
              borderRadius: BorderRadius.circular(35),
              elevation: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Appointment Details",
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "With: $displayName",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              _formatAppointmentTime(appointment),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Status: Completed",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (appointment["feedback"] != null) ...[
                        const SizedBox(height: 8),
                        const Text(
                          "Feedback:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(appointment["feedback"]),
                      ],
                      if (appointment["imageUrl"] != null &&
                          appointment["imageUrl"].isNotEmpty) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            appointment["imageUrl"],
                            height: 280,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image,
                                    size: 100, color: Colors.grey),
                          ),
                        ),
                      ],
                      const SizedBox(height: 5),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Close"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
