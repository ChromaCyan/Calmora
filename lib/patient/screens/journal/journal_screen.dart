import 'package:armstrong/widgets/navigation/appbar.dart';
import 'package:flutter/material.dart';
import 'package:armstrong/config/colors.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/services/api.dart';
import 'dart:convert';


class JournalPage extends StatefulWidget {
  const JournalPage({Key? key}) : super(key: key);

  @override
  _JournalPageState createState() => _JournalPageState();
}
class _JournalPageState extends State<JournalPage> {
  String? _userId;
  int? _selectedMood;
  final TextEditingController _daySummaryController = TextEditingController();
  final ApiRepository _apiRepository = ApiRepository();
  bool hasAnsweredMoodToday = false;
  List<Map<String, dynamic>> _moods = [];

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _checkMoodStatus();
  }

  Future<void> _loadUserId() async {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    final userId = await storage.read(key: 'userId');
    setState(() {
      _userId = userId;
    });
  }

  Future<void> _checkMoodStatus() async {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    final lastMoodDate = await storage.read(key: 'lastMoodDate');
    final today = DateTime.now().toIso8601String().split('T')[0];

    if (lastMoodDate == today) {
      setState(() {
        hasAnsweredMoodToday = true;
      });
      // Fetch mood entries if already filled for today
      await _fetchMoodEntries();
    } else {
      setState(() {
        hasAnsweredMoodToday = false;
      });
    }
  }

  Future<void> _fetchMoodEntries() async {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    final savedMood = await storage.read(key: 'savedMood');

    if (savedMood != null) {
      setState(() {
        final moodData = Map<String, dynamic>.from(jsonDecode(savedMood));
        _moods = [moodData];  // Convert the saved mood to a list
      });
    }
  }

  Future<void> _saveMoodEntry() async {
    if (_selectedMood == null || _daySummaryController.text.isEmpty) {
      _showError('Please select a mood and enter a summary');
      return;
    }

    try {
      final result = await _apiRepository.createMoodEntry(
        _selectedMood!,
        _daySummaryController.text,
      );

      // Save the mood entry locally to secure storage
      final moodData = {
        'moodScale': _selectedMood,
        'moodDescription': _daySummaryController.text,
        'createdAt': DateTime.now().toIso8601String(),
      };
      final FlutterSecureStorage storage = FlutterSecureStorage();
      await storage.write(key: 'savedMood', value: jsonEncode(moodData));
      await _saveLastMoodDate();

      // Update UI and show success message
      setState(() {
        _moods = [moodData];
      });
      _showSuccess(result['message']);
    } catch (e) {
      _showError('Failed to save mood entry: $e');
    }
  }

  Future<void> _saveLastMoodDate() async {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    final today = DateTime.now().toIso8601String().split('T')[0];
    await storage.write(key: 'lastMoodDate', value: today);
    setState(() {
      hasAnsweredMoodToday = true;
    });
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildMoodSelector() {
    return Column(
      children: [
        _moodRadio('Very Happy 😊', 5, Colors.green),
        _moodRadio('Happy 🙂', 4, Colors.lightGreen),
        _moodRadio('Neutral 😐', 3, Colors.yellow),
        _moodRadio('Sad ☹️', 2, Colors.orange),
        _moodRadio('Very Sad 😭', 1, Colors.red),
      ],
    );
  }

  Widget _moodRadio(String label, int mood, Color color) {
    return RadioListTile<int>(
      title: Text(label),
      value: mood,
      groupValue: _selectedMood,
      onChanged: (int? selected) {
        if (selected != null) {
          setState(() {
            _selectedMood = selected;
          });
        }
      },
      secondary: CircleAvatar(
        backgroundColor: color,
        child: Text(mood.toString(), style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _journalTextField({required TextEditingController controller}) {
    return TextField(
      controller: controller,
      maxLines: 6,
      decoration: InputDecoration(
        hintText: 'Write your journal entry...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.all(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: UniversalAppBar(
        title: "Journal Screen",
        onBackPressed: () {
          Navigator.pop(context);
        },
        actions: [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Log Your Mood',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Show mood selector if the user has not yet answered today
            if (!hasAnsweredMoodToday) ...[
              _buildMoodSelector(),
              const SizedBox(height: 20),
              const Text(
                'Day Summary:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              _journalTextField(controller: _daySummaryController),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveMoodEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Save Entry',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
            // If mood already answered today, show message and mood entries
            if (hasAnsweredMoodToday) ...[
              const Text(
                'You have already answered your mood for today.',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.green),
              ),
              const SizedBox(height: 20),
              // Display mood summaries as text entries
              if (_moods.isEmpty)
                const Text('No mood data available.')
              else
                ..._moods.map((mood) {
                  DateTime date = DateTime.parse(mood['createdAt']);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Mood: ${mood['moodScale']}, Summary: ${mood['moodDescription']} (Date: ${date.toLocal().toString().split(' ')[0]})',
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                }).toList(),
            ],
          ],
        ),
      ),
    );
  }
}
