import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentDetailsDialog extends StatelessWidget {
  final dynamic appointment;

  const AppointmentDetailsDialog({super.key, required this.appointment});

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) return "N/A";
    final dateTime = DateTime.parse(dateTimeString);
    return DateFormat("MMM dd, yyyy - hh:mm a").format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.hardEdge, // Prevents render errors
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 500), // Limit height
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Appointment Details",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  "With: ${appointment["specialist"] != null ? "${appointment["specialist"]["firstName"]} ${appointment["specialist"]["lastName"]}" : appointment["patient"]?["firstName"] ?? "Unknown"}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18),
                    const SizedBox(width: 6),
                    Text(_formatDateTime(appointment["startTime"])),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "Status: Completed",
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
                if (appointment["feedback"] != null) ...[
                  const SizedBox(height: 8),
                  const Text("Feedback:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(appointment["feedback"]),
                ],
                if (appointment["imageUrl"] != null && appointment["imageUrl"].isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      appointment["imageUrl"],
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100, color: Colors.grey),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
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
    );
  }
}
