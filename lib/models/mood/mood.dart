import 'package:intl/intl.dart';

class MoodEntry {
  final int moodScale;
  final DateTime createdAt;

  MoodEntry({required this.moodScale, required this.createdAt});

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      moodScale: json['moodScale'],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // Convert DateTime to String if needed for UI purposes
  String get formattedDate => DateFormat('yyyy-MM-dd').format(createdAt);
}
