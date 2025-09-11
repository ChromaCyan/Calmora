import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentDetailsDialog extends StatelessWidget {
  final dynamic appointment;

  const AppointmentDetailsDialog({super.key, required this.appointment});

  String _formatAppointmentTime(dynamic appointment) {
    if (appointment["appointmentDate"] == null || appointment["timeSlot"] == null) {
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
    return Stack(
      children: [
        // 🔹 Background blur when dialog opens
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(color: Colors.black.withOpacity(0.2)), // subtle dim
        ),

        // 🔹 Centered dialog box
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Material(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              elevation: 12,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        "Appointment Details",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),

                      // Specialist / Patient
                      Text(
                        "With: ${appointment["specialist"] != null ? "${appointment["specialist"]["firstName"]} ${appointment["specialist"]["lastName"]}" : appointment["patient"]?["firstName"] ?? "Unknown"}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Time
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

                      // Status
                      const Text(
                        "Status: Completed",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Feedback
                      if (appointment["feedback"] != null) ...[
                        const SizedBox(height: 8),
                        const Text(
                          "Feedback:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(appointment["feedback"]),
                      ],

                      // Image
                      if (appointment["imageUrl"] != null &&
                          appointment["imageUrl"].isNotEmpty) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            appointment["imageUrl"],
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image,
                                    size: 100, color: Colors.grey),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Close button
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
