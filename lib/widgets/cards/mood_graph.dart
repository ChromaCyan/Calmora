import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:armstrong/models/mood/mood.dart';
import 'package:armstrong/services/api.dart';
import 'package:intl/intl.dart';

class MoodCalendarScreen extends StatefulWidget {
  final String userId;
  const MoodCalendarScreen({super.key, required this.userId});

  @override
  State<MoodCalendarScreen> createState() => _MoodCalendarScreenState();
}

class _MoodCalendarScreenState extends State<MoodCalendarScreen> {
  late Future<List<MoodEntry>> futureMoods;
  DateTime focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    futureMoods = ApiRepository().getMoodEntries(widget.userId);
  }

  List<DateTime> getWeekDays(DateTime date) {
    DateTime startOfWeek = date.subtract(Duration(days: date.weekday % 7));
    return List.generate(7, (index) => DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day + index));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<MoodEntry>>(
          future: futureMoods,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No mood data found.'));
            }

            // Normalize mood dates to remove time
            Map<DateTime, int> moodData = {
              for (var mood in snapshot.data!)
                DateTime(mood.createdAt.year, mood.createdAt.month, mood.createdAt.day): mood.moodScale
            };

            int weekOfMonth = ((focusedDay.day - 1) ~/ 7) + 1;
            List<DateTime> weekDays = getWeekDays(focusedDay);

            // Filter moods to only those in the selected week
            List<DateTime> weekMoods = moodData.keys.where((date) => weekDays.contains(date)).toList()
              ..sort((a, b) => a.compareTo(b)); // Sort by date

            return Column(
              children: [
                Text(
                  'Week $weekOfMonth of ${DateFormat('MMMM yyyy').format(focusedDay)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                TableCalendar(
                  focusedDay: focusedDay,
                  firstDay: DateTime.utc(2025, 1, 1),
                  lastDay: DateTime.now(),
                  calendarFormat: CalendarFormat.week,
                  onPageChanged: (date) => setState(() => focusedDay = date),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                ),

                const SizedBox(height: 16),

                weekMoods.isEmpty
                    ? const Center(child: Text('No moods recorded this week.'))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: weekMoods.length,
                        itemBuilder: (context, index) {
                          DateTime day = weekMoods[index];
                          String weekday = DateFormat('EEEE').format(day);
                          String formattedDate = DateFormat('MMMM d').format(day);
                          int? moodScale = moodData[day];

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: ListTile(
                              leading: getMoodImage(moodScale),
                              title: Text(
                                '$weekday, $formattedDate',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                getMoodDescription(moodScale!),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          );
                        },
                      ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget getMoodImage(int? moodScale) {
    String imagePath;
    switch (moodScale) {
      case 1:
        imagePath = "images/icons/depression.png";
        break;
      case 2:
        imagePath = "images/icons/mental-disorder.png";
        break;
      case 3:
        imagePath = "images/icons/relax.png";
        break;
      case 4:
        imagePath = "images/icons/very-happy.png";
        break;
      default:
        imagePath = "images/icons/dunno.png";
    }
    return Image.asset(imagePath, width: 50, height: 50);
  }

  String getMoodDescription(int moodScale) {
    switch (moodScale) {
      case 1:
        return "Today might have been tough, but you're tougher. Keep going!";
      case 2:
        return "Not the best day, and that's okay. Tomorrow is a fresh start.";
      case 3:
        return "You were in a good place today. Keep finding those moments of joy!";
      case 4:
        return "You were feeling great today! Savor those good vibes.";
      default:
        return "No mood recorded, but every day is a step forward!";
    }
  }
}
