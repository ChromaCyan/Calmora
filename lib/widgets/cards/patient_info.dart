import 'package:flutter/material.dart';

class PatientInfoWidget extends StatelessWidget {
  final String userId;

  const PatientInfoWidget({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchPatientInfo(userId), 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData) {
          return Text('No data found');
        } else {
          final patientData = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text('${patientData['firstName']} ${patientData['lastName']}'),
                subtitle: Text('Email: ${patientData['email']}'),
              ),
              ListTile(
                title: Text('Phone: ${patientData['phoneNumber']}'),
              ),
              if (patientData['address'] != null)
                ListTile(
                  title: Text('Address: ${patientData['address']}'),
                ),
              if (patientData['dateOfBirth'] != null)
                ListTile(
                  title: Text('Date of Birth: ${patientData['dateOfBirth']}'),
                ),
              if (patientData['emergencyContact'] != null)
                ListTile(
                  title: Text('Emergency Contact: ${patientData['emergencyContact']['name']}'),
                  subtitle: Text('Phone: ${patientData['emergencyContact']['phone']}'),
                ),
              if (patientData['medicalHistory'] != null)
                ListTile(
                  title: Text('Medical History: ${patientData['medicalHistory']}'),
                ),
            ],
          );
        }
      },
    );
  }
}
