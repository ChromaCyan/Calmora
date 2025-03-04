import 'package:armstrong/widgets/navigation/appbar.dart';
import 'package:flutter/material.dart';
import 'package:armstrong/config/colors.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/services/api.dart';
import 'dart:convert';
import 'package:armstrong/widgets/buttons/mood_select.dart';

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

      final moodData = {
        'moodScale': _selectedMood,
        'moodDescription': _daySummaryController.text,
        'createdAt': DateTime.now().toIso8601String(),
      };
      final FlutterSecureStorage storage = FlutterSecureStorage();
      await storage.write(key: 'savedMood', value: jsonEncode(moodData));
      await _saveLastMoodDate();

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

  Widget _journalTextField(BuildContext context, {required TextEditingController controller}) {
    final theme = Theme.of(context);
    bool isDarkMode = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        double fontSize = (constraints.maxWidth * 0.04).clamp(12.0, 18.0); // Min 12px, Max 18px

        return TextFormField(
          controller: controller,
          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: fontSize),
          decoration: InputDecoration(
            labelText: 'Day Summary',
            labelStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: fontSize * 0.9),
            hintText: 'Write about your day...',
            hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: fontSize * 0.9),
            prefixIcon: Icon(Icons.book, color: theme.colorScheme.onSurfaceVariant, size: fontSize * 1.2),
            filled: true,
            fillColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline,
                width: 1,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: fontSize * 2, horizontal: fontSize),
          ),
          minLines: 5,
          maxLines: 7,
        );
      },
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Log Your Mood',
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            MoodSelect(
              selectedMood: _selectedMood,
              onMoodSelected: (int mood) {
                setState(() {
                  _selectedMood = mood;
                });
              },
            ),
            const SizedBox(height: 20),
            _journalTextField(context, controller: _daySummaryController),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveMoodEntry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: FittedBox(
                      child: Text(
                        'Save Entry',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1, // Ensures text stays in one line
                        overflow: TextOverflow.ellipsis, // Prevents overflow issues
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
