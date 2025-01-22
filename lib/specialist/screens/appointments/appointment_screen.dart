import 'package:armstrong/config/colors.dart';
import 'package:armstrong/specialist/screens/appointments/appointment_complete_screen.dart';
import 'package:armstrong/specialist/screens/appointments/appointment_request_screen.dart';
import 'package:flutter/material.dart';

class AppointmentsScreen extends StatelessWidget {
  final List<Map<String, String?>> requestAppointments = [
    {
      "name": "Jane Doe",
      "specialty": "Patient",
      "location": "St. Bronxlyn 212",
      "date": "Monday, 28 April 2018",
      "color": "0xFFFFCCBC",
      "rating": "4.5",
      "time": "10:00 AM", 
    },
    {
      "name": "John Smith",
      "specialty": "Patient",
      "location": "St. Bronxlyn 212",
      "date": "Monday, 29 April 2018",
      "color": "0xFFB3E5FC",
      "rating": "4.4",
      "time": "3:00 PM", 
    },
  ];

  final List<Map<String, String?>> acceptedAppointments = [
    {
      "name": "Dudung Sokmati",
      "specialty": "Patient",
      "location": "St. Bronxlyn 212",
      "date": "Monday, 26 April 2018",
      "color": "0xFFB2DFDB",
      "rating": "4.9",
      "time": "11:00 AM", 
    },
    {
      "name": "Nunung Brandon",
      "specialty": "Patient",
      "location": "St. Bronxlyn 212",
      "date": "Monday, 26 April 2018",
      "color": "0xFFB2EBF2",
      "rating": "4.8",
      "time": "2:00 PM", 
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
                              name: appointment["name"]!,
                              specialty: appointment["specialty"]!,
                              color: Color(int.parse(appointment["color"]!)),
                              rating: appointment["rating"]!,
                              location: appointment["location"]!,
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
                              name: appointment["name"]!,
                              specialty: appointment["specialty"]!,
                              color: Color(int.parse(appointment["color"]!)),
                              rating: appointment["rating"]!,
                              date: appointment["date"]!,
                              location: appointment["location"]!,
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
                  appointment["name"]?[0] ?? "",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                appointment["name"] ?? "",
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
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16.0, color: Colors.grey),
                      const SizedBox(width: 4.0),
                      Text(appointment["location"] ?? ""),
                    ],
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
