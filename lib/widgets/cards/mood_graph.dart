// import 'package:flutter/material.dart';
// import 'package:armstrong/services/api.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class MoodChartScreen extends StatefulWidget {
//   const MoodChartScreen({Key? key}) : super(key: key);

//   @override
//   _MoodChartScreenState createState() => _MoodChartScreenState();
// }

// class _MoodChartScreenState extends State<MoodChartScreen> {
//   final ApiRepository _apiRepository = ApiRepository();
//   String? _userId;
//   List<Map<String, dynamic>> _moods = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadMoods();
//     _loadUserId();
//   }

//   Future<void> _loadUserId() async {
//     final FlutterSecureStorage storage = FlutterSecureStorage();
//     final userId = await storage.read(key: 'userId');
//     setState(() {
//       _userId = userId;
//     });
//   }

//   Future<void> _loadMoods() async {
//   try {
//     final userId = _userId;
//     if (userId != null) {
//       final moodEntries = await _apiRepository.getMoodEntries(userId);
//       print("Mood Data: $moodEntries");  // Log the response
//       setState(() {
//         _moods = List<Map<String, dynamic>>.from(moodEntries);
//       });
//     }
//   } catch (e) {
//     print("Error loading mood data: $e");
//   }
// }
//   @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     body: Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Mood Tracker - Last 7 Days',
//             style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 20),
//           if (_moods.isEmpty)
//             const Center(child: CircularProgressIndicator())
//           else if (_moods == null || _moods.isEmpty)
//             const Center(child: Text("No mood data available."))
//           else
//             _buildBarChart(),
//         ],
//       ),
//     ),
//   );
// }

//   Widget _buildBarChart() {
//     return Container(
//       height: 300,
//       width: double.infinity,
//       child: BarChart(
//         BarChartData(
//           gridData: FlGridData(show: false),
//           titlesData: FlTitlesData(
//             leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
//             bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
//           ),
//           borderData: FlBorderData(show: true),
//           barGroups: _moods.map((mood) {
//             DateTime date = DateTime.parse(mood['createdAt']);
//             return BarChartGroupData(
//               x: date.millisecondsSinceEpoch,
//               barRods: [
//                 BarChartRodData(
//                   toY: mood['moodScale'].toDouble(),
//                   color: _getMoodColor(mood['moodScale']),
//                   width: 15,
//                   borderRadius: BorderRadius.zero,
//                 ),
//               ],
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }

//   Color _getMoodColor(int moodScale) {
//     switch (moodScale) {
//       case 5:
//         return Colors.green; // Very happy
//       case 4:
//         return Colors.lightGreen; // Happy
//       case 3:
//         return Colors.yellow; // Neutral
//       case 2:
//         return Colors.orange; // Sad
//       case 1:
//         return Colors.red; // Very sad
//       default:
//         return Colors.grey;
//     }
//   }
// }

import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MoodChartScreen extends StatefulWidget {
  const MoodChartScreen({super.key});

  @override
  State<MoodChartScreen> createState() => _MoodChartScreenState();
}

class _MoodChartScreenState extends State<MoodChartScreen> {
  List<Color> gradientColors = const [
    Color(0xffEEF3FE),
    Color(0xffEEF3FE),
  ];

  bool showAvg = false;

  // Mood labels corresponding to the Y-values
  final List<String> moodLabels = [
    'Very Sad', // Value 1
    'Sad', // Value 2
    'Happy', // Value 4
    'Very Happy', // Value 5
  ];

  // Emoji icons for moods
  final List<String> moodEmojis = [
    '😞', // Very Sad
    '😟', // Sad
    '🙂', // Happy
    '😊', // Very Happy
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1.70,
            child: Padding(
              padding: const EdgeInsets.only(
                right: 18,
                left: 12,
                top: 24,
                bottom: 12,
              ),
              child: LineChart(
                mainData(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Days on top (Monday, Tuesday, etc.)
  Widget topTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 12,
      color: Colors.black,
    );
    List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return SideTitleWidget(
      meta: meta,
      child: Text(days[value.toInt()], style: style),
    );
  }

  // Using emoji icons instead of images
  Widget leftTitleWidgets(double value, TitleMeta meta) {
    String emoji = moodEmojis[(value ~/ 2).toInt()]; 
    return Text(
      emoji,
      style: TextStyle(fontSize: 24), // Adjust emoji size
    );
  }

  // Show mood label when touching a point
  List<TouchedSpotIndicatorData> getTouchedSpotIndicator(
      LineChartBarData barData, List<int> spotIndexes) {
    return spotIndexes.map((spotIndex) {
      // Get the Y-value at the touched spot
      double yValue = barData.spots[spotIndex].y;

      // Map Y-value to mood label
      String mood = moodLabels[(yValue ~/ 2).toInt()];

      return TouchedSpotIndicatorData(
        const FlLine(color: Colors.orange, strokeWidth: 3),
        FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) =>
              FlDotCirclePainter(
            radius: 8,
            color: Colors.orange,
          ),
        ),
      );
    }).toList();
  }

  LineChartData mainData() {
    return LineChartData(
      rangeAnnotations: RangeAnnotations(
        verticalRangeAnnotations: [],
      ),
      gridData: const FlGridData(
        show: true,
        drawVerticalLine: false,
        drawHorizontalLine: false,
        verticalInterval: 1,
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36,
            getTitlesWidget: topTitleWidgets,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          drawBelowEverything: true,
          sideTitles: SideTitles(
            interval: 2,
            showTitles: true,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 40,
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      lineTouchData: LineTouchData(
        getTouchLineEnd: (data, index) => double.infinity,
        getTouchedSpotIndicator: getTouchedSpotIndicator, 
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: Colors.grey,
        ),
      ),
      minX: 0,
      maxX: 6,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 1),
            FlSpot(1, 2),
            FlSpot(2, 3),
            FlSpot(3, 4),
            FlSpot(4, 4),
            FlSpot(5, 3),
            FlSpot(6, 2),
          ],
          isCurved: true,
          color: Colors.orange,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(show: false),
        ),
      ],
    );
  }
}
