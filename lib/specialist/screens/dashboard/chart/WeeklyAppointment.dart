import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:armstrong/services/api.dart';

class WeeklyAppointmentChart extends StatefulWidget {
  final String specialistId;

  const WeeklyAppointmentChart({Key? key, required this.specialistId})
      : super(key: key);

  @override
  _WeeklyAppointmentChartState createState() => _WeeklyAppointmentChartState();
}

class _WeeklyAppointmentChartState extends State<WeeklyAppointmentChart> {
  final ApiRepository _apiRepository = ApiRepository();
  List<dynamic> weeklyData = [];
  bool isLoading = true;
  String errorMessage = '';
  DateTime _currentWeek = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchWeeklyCompletedAppointments(_currentWeek);
  }

  Future<void> _fetchWeeklyCompletedAppointments(DateTime date) async {
    try {
      DateTime startOfWeek = _getStartOfWeek(date);
      DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));

      final data =
          await _apiRepository.getSpecialistWeeklyCompletedAppointments(
        widget.specialistId,
        startDate: DateFormat('yyyy-MM-dd').format(startOfWeek),
        endDate: DateFormat('yyyy-MM-dd').format(endOfWeek),
      );

      weeklyData = List.generate(7, (index) {
        DateTime day = startOfWeek.add(Duration(days: index));
        var foundDay = data.firstWhere(
          (item) => item['date'] == DateFormat('yyyy-MM-dd').format(day),
          orElse: () => {'count': 0},
        );

        return {
          'day': DateFormat('EEE').format(day),
          'count': foundDay['count'] ?? 0,
        };
      });

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  // Color mapping for days (Monday to Sunday)
  final Map<int, List<Color>> _dayColors = {
    0: [Colors.red[400]!, Colors.red[200]!], // Monday
    1: [Colors.orange[400]!, Colors.orange[200]!], // Tuesday
    2: [Colors.yellow[600]!, Colors.yellow[300]!], // Wednesday
    3: [Colors.green[400]!, Colors.green[200]!], // Thursday
    4: [Colors.blue[400]!, Colors.blue[200]!], // Friday
    5: [Colors.purple[400]!, Colors.purple[200]!], // Saturday
    6: [Colors.pink[400]!, Colors.pink[200]!], // Sunday
  };

  DateTime _getStartOfWeek(DateTime date) {
    int dayOfWeek = date.weekday;
    return date.subtract(Duration(days: dayOfWeek - 1));
  }

  void _changeWeek(int direction) {
    setState(() {
      _currentWeek = _currentWeek.add(Duration(days: 7 * direction));
      isLoading = true;
    });
    _fetchWeeklyCompletedAppointments(_currentWeek);
  }

  String _getWeekLabel(DateTime date) {
    int weekOfMonth = ((date.day - 1) ~/ 7) + 1;
    String monthName = DateFormat('MMMM').format(date);
    return 'Week $weekOfMonth of $monthName';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (errorMessage.isNotEmpty) {
      return Center(child: Text('Error: $errorMessage'));
    }

    return Column(
      children: [
        // Week Navigation Bar
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous Week Button
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _changeWeek(-1),
              ),
              // Week Label
              Text(
                _getWeekLabel(_currentWeek),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              // Next Week Button
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () => _changeWeek(1),
              ),
            ],
          ),
        ),

        // Appointment Chart
        AspectRatio(
          aspectRatio: 1.6,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[900]
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: _getBarChartData(),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: _getTitles,
                      reservedSize: 24,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                maxY: _getMaxY(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Generate bar chart data
  List<BarChartGroupData> _getBarChartData() {
  return List.generate(weeklyData.length, (index) {
    final weekData = weeklyData[index];

    // Get colors based on day index
    List<Color> dayColors = _dayColors[index % 7] ?? [Colors.grey, Colors.grey];

    return BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(
          toY: weekData['count'].toDouble(),
          width: 16,
          gradient: LinearGradient(
            colors: dayColors,
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  });
}


  // Bottom day titles
  Widget _getTitles(double value, TitleMeta meta) {
    if (value >= 0 && value < weeklyData.length) {
      return Text(
        weeklyData[value.toInt()]['day'],
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
    }
    return const Text('');
  }

  double _getMaxY() {
    double maxY = weeklyData.isNotEmpty
        ? weeklyData
            .map((item) => item['count'].toDouble())
            .reduce((a, b) => a > b ? a : b)
        : 10;
    return maxY == 0 ? 5 : maxY + 5; 
  }
}
