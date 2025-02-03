// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';

// class AppointmentsChart extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         return Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: LineChart(
//             LineChartData(
//               titlesData: FlTitlesData(
//                 leftTitles: AxisTitles(
//                   sideTitles: SideTitles(
//                     showTitles: true,
//                     reservedSize: 40,
//                     getTitlesWidget: (value, meta) {
//                       // Show labels only for multiples of 10
//                       return value % 10 == 0 ? Text("${value.toInt()}") : Container();
//                     },
//                   ),
//                 ),
//                 bottomTitles: AxisTitles(
//                   sideTitles: SideTitles(
//                     showTitles: true,
//                     reservedSize: 30,
//                     getTitlesWidget: (value, meta) {
//                       // Show labels for every 2 weeks
//                       return value % 2 == 0 ? Text("Week ${value.toInt()}") : Container();
//                     },
//                   ),
//                 ),
//               ),
//               borderData: FlBorderData(show: false),
//               lineBarsData: [
//                 LineChartBarData(
//                   spots: [
//                     FlSpot(1, 10),
//                     FlSpot(2, 20),
//                     FlSpot(3, 15),
//                     FlSpot(4, 25),
//                     FlSpot(5, 18),
//                     FlSpot(6, 30),
//                   ],
//                   isCurved: true,
//                   color: Color(0xFF64B5F6),
//                   barWidth: 4,
//                   isStrokeCapRound: true,
//                   belowBarData: BarAreaData(
//                     show: true,
//                     color: Color(0xFF81C784).withOpacity(0.3),
//                   ),
//                 ),
//               ],
//               gridData: FlGridData(show: false),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }