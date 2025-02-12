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
        _moods = [moodData];  
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
        _moodRadio('Very Happy 😊', 4, Colors.green),
        _moodRadio('Happy 🙂', 3, Colors.lightGreen),
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

  Widget _journalTextField(BuildContext context, {required TextEditingController controller}) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      maxLines: 6,
      decoration: InputDecoration(
        hintText: 'Write your journal entry...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.all(12),
        filled: true,
        fillColor: theme.colorScheme.surfaceVariant,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            Text(
              'Log Your Mood',
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (!hasAnsweredMoodToday) ...[
              _buildMoodSelector(),
              const SizedBox(height: 20),
              Text(
                'Day Summary:',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _journalTextField(context, controller: _daySummaryController),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveMoodEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Save Entry',
                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
            if (hasAnsweredMoodToday) ...[
              Text(
                'You have already answered your mood for today.',
                style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 20),
              if (_moods.isEmpty)
                Text('No mood data available.', style: theme.textTheme.bodyLarge)
              else
                ..._moods.map((mood) {
                  DateTime date = DateTime.parse(mood['createdAt']);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Mood: ${mood['moodScale']}, Summary: ${mood['moodDescription']} (Date: ${date.toLocal().toString().split(' ')[0]})',
                      style: theme.textTheme.bodyMedium,
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