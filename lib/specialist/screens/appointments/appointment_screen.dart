import 'package:armstrong/config/colors.dart';
import 'package:armstrong/specialist/screens/appointments/appointment_complete_screen.dart';
import 'package:armstrong/specialist/screens/appointments/appointment_request_screen.dart';
import 'package:flutter/material.dart';

class AppointmentsScreen extends StatelessWidget {
  final List<Map<String, String?>> requestAppointments = [
    {
      "fullName": "John Kevin",
      "specialty": "General Checkup",
      "reason": "Routine Examination",
      "phoneNumber": "123-456-7890",
      "email": "john@gmail.com",
      "address": "123 Main St, Springfield",
      "time": "10:00 AM",
      "date": "Saturday, 25 January 2025",
      "color": "0xFFFFCCBC",
    },
  ];

  final List<Map<String, String?>> acceptedAppointments = [
    {
      "fullName": "Dudung Sokmati",
      "specialty": "Cardiology",
      "reason": "Follow-up Visit",
      "phoneNumber": "111-222-3333",
      "email": "dudung@gmail.com",
      "address": "789 Oak St, Springfield",
      "time": "11:00 AM",
      "date": "Monday, 20 Januarary 2025",
      "color": "0xFFB2DFDB",
      "rating": "5",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            Container(
              color: Colors.transparent,
              child: const TabBar(
                tabs: [
                  Tab(text: "Request"),
                  Tab(text: "Completed"),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  AppointmentList(
                    appointments: requestAppointments,
                    onTap: (appointment) {
                      if (appointment != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AppointmentDetailScreen(
                              fullName: appointment["fullName"]!,
                              specialty: appointment["specialty"]!,
                              reason: appointment["reason"]!,
                              phoneNumber: appointment["phoneNumber"]!,
                              email: appointment["email"]!,
                              address: appointment["address"]!,
                              time: appointment["time"]!,
                              date: appointment["date"]!,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  AppointmentList(
                    appointments: acceptedAppointments,
                    onTap: (appointment) {
                      if (appointment != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CompletedAppointmentDetail(
                              fullName: appointment["fullName"]!,
                              specialty: appointment["specialty"]!,
                              reason: appointment["reason"]!,
                              phoneNumber: appointment["phoneNumber"]!,
                              email: appointment["email"]!,
                              address: appointment["address"]!,
                              time: appointment["time"]!,
                              date: appointment["date"]!,
                              rating: appointment["rating"]!,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppointmentList extends StatelessWidget {
  final List<Map<String, String?>> appointments;
  final void Function(Map<String, String?>?) onTap;

  const AppointmentList({
    Key? key,
    required this.appointments,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return GestureDetector(
          onTap: () => onTap(appointment),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: appointment["color"] != null
                    ? Color(int.parse(appointment["color"]!))
                    : Colors.grey,
                radius: 30.0,
                child: Text(
                  appointment["fullName"]?[0] ?? "",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                appointment["fullName"] ?? "",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment["specialty"] ?? "",
                    style: const TextStyle(color: orangeContainer),
                  ),
                  const SizedBox(height: 4.0),
                  Text(appointment["date"] ?? ""),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
