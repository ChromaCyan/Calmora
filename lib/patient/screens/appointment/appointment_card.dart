import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:armstrong/config/colors.dart';

class AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;

  const AppointmentCard({Key? key, required this.appointment})
      : super(key: key);

  String _formatDate(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    return DateFormat('MMM d, y').format(dateTime);
  }

  String _formatTime(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    return DateFormat('h:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final specialist = appointment['specialist'];
    final specialistName = '${specialist['firstName']} ${specialist['lastName']}';
    final startTime = appointment['startTime'];
    final endTime = appointment['endTime'];
    final status = appointment['status'];

    final formattedStartDate = _formatDate(startTime);
    final formattedStartTime = _formatTime(startTime);
    final formattedEndTime = _formatTime(endTime);
    final formattedCombinedTime = '$formattedStartTime - $formattedEndTime';

    return Center(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.22,
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          specialistName,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Status: ${status[0].toUpperCase() + status.substring(1)}',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                            color: status == 'pending'
                                ? Colors.orange
                                : status == 'accepted'
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                //SPECIALIST PROFILE IMG *start*
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.07,
                    width: MediaQuery.of(context).size.width * 0.2,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage("lib/icons/profile_placeholder.png"), //Display the Specialist profile picture here
                        filterQuality: FilterQuality.high,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                //SPECIALIST PROFILE IMAGE *end*
                
              ],
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.03,
              width: MediaQuery.of(context).size.width * 0.85,
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: orangeContainer,
                    size: 18.0,
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    formattedStartDate,
                    style: TextStyle(fontSize: 16.0, color: Colors.black54),
                  ),
                  SizedBox(width: 12.0),
                  Icon(
                    Icons.lock_clock,
                    color: buttonColor,
                    size: 18.0,
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    formattedCombinedTime,
                    style: TextStyle(fontSize: 16.0, color: Colors.black54),
                  ),
                ],
              ),
            ),

            //RESCHEDULE AND CANCEL PART *start*
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.045,
                    width: MediaQuery.of(context).size.width * 0.38,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 232, 233, 233),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 61, 61, 61),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.045,
                    width: MediaQuery.of(context).size.width * 0.38,
                    decoration: BoxDecoration(
                      color: Color(0xFF81C784),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "Reschedule",
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //RESCHEDULE AND CANCEL PART *end*

          ],
        ),
      ),
    );
  }
}
