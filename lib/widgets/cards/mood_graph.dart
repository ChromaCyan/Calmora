import 'package:flutter/material.dart';
import 'package:armstrong/services/api.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MoodChartScreen extends StatefulWidget {
  const MoodChartScreen({Key? key}) : super(key: key);

  @override
  _MoodChartScreenState createState() => _MoodChartScreenState();
}

class _MoodChartScreenState extends State<MoodChartScreen> {
  final ApiRepository _apiRepository = ApiRepository();
  String? _userId;
  List<Map<String, dynamic>> _moods = [];

  @override
  void initState() {
    super.initState();
    _loadMoods();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    final userId = await storage.read(key: 'userId');
    setState(() {
      _userId = userId;
    });
  }

  Future<void> _loadMoods() async {
  try {
    final userId = _userId;
    if (userId != null) {
      final moodEntries = await _apiRepository.getMoodEntries(userId);
      print("Mood Data: $moodEntries");  // Log the response
      setState(() {
        _moods = List<Map<String, dynamic>>.from(moodEntries);
      });
    }
  } catch (e) {
    print("Error loading mood data: $e");
  }
}
  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mood Tracker - Last 7 Days',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          if (_moods.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (_moods == null || _moods.isEmpty)
            const Center(child: Text("No mood data available."))
          else
            _buildBarChart(),
        ],
      ),
    ),
  );
}

  Widget _buildBarChart() {
    return Container(
      height: 300, // Set the height for the graph
      width: double.infinity, // Ensure the chart takes the full available width
      child: BarChart(
        BarChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          ),
          borderData: FlBorderData(show: true),
          barGroups: _moods.map((mood) {
            DateTime date = DateTime.parse(mood['createdAt']);
            return BarChartGroupData(
              x: date.millisecondsSinceEpoch,
              barRods: [
                BarChartRodData(
                  toY: mood['moodScale'].toDouble(),
                  color: _getMoodColor(mood['moodScale']),
                  width: 15,
                  borderRadius: BorderRadius.zero,
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getMoodColor(int moodScale) {
    switch (moodScale) {
      case 5:
        return Colors.green; // Very happy
      case 4:
        return Colors.lightGreen; // Happy
      case 3:
        return Colors.yellow; // Neutral
      case 2:
        return Colors.orange; // Sad
      case 1:
        return Colors.red; // Very sad
      default:
        return Colors.grey;
    }
  }
}
