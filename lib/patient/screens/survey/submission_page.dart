// import 'package:flutter/material.dart';

// class SubmissionScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Your form has been submitted!',
//               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.popUntil(context, (route) => route.isFirst);
//               },
//               style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF81C784)),
//               child: Text('Go Back', style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }