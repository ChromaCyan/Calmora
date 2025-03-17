import 'package:armstrong/widgets/navigation/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/services/api.dart';
import 'dart:convert';
import 'package:armstrong/widgets/buttons/mood_select.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

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
      _showError('Incomplete Fields!',
          'Please select a mood and enter a summary', ContentType.warning);
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

      _showSuccess('Mood Logged!',
          'Your mood entry has been saved successfully.', ContentType.success);

      // Delay before navigating back so the user sees the success message
      Future.delayed(const Duration(seconds: 2), () {
        if (context.mounted) {
          Navigator.pop(context);
        }
      });
    } catch (e) {
      _showError('Mood failed to save..', 'Failed to save mood entry: $e',
          ContentType.failure);
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

  void _showSuccess(String title, String message, ContentType type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: title,
          message: message,
          contentType: type,
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showError(String title, String message, ContentType type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: title,
          message: message,
          contentType: type,
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _journalTextField(BuildContext context,
      {required TextEditingController controller}) {
    final theme = Theme.of(context);
    bool isDarkMode = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        double fontSize = (constraints.maxWidth * 0.04)
            .clamp(12.0, 18.0); // Min 12px, Max 18px

        return TextFormField(
          controller: controller,
          style:
              TextStyle(color: theme.colorScheme.onSurface, fontSize: fontSize),
          decoration: InputDecoration(
            labelText:
                'Reflect on Your day! \n \nUnpack your thoughts for today.. ',
            labelStyle: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: fontSize * 0.9),
            hintText: 'Write about your day...',
            hintStyle: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: fontSize * 0.9),
            prefixIcon: Icon(Icons.book,
                color: theme.colorScheme.onSurfaceVariant,
                size: fontSize * 1.2),
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
            contentPadding: EdgeInsets.symmetric(
                vertical: fontSize * 2, horizontal: fontSize),
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
        title: "Mood Screen",
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Text(
                'How are you holding up? 💪',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),

            // Mood selection with stylish design
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: MoodSelect(
                  selectedMood: _selectedMood,
                  onMoodSelected: (int mood) {
                    setState(() {
                      _selectedMood = mood;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Journal Entry Field
            _journalTextField(context, controller: _daySummaryController),

            const SizedBox(height: 24),

            // Save Button with Gradient Styling
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveMoodEntry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ).copyWith(
                      backgroundColor: MaterialStateProperty.resolveWith(
                        (states) => states.contains(MaterialState.pressed)
                            ? Colors.green.shade700
                            : Colors.green.shade500,
                      ),
                    ),
                    child: Text(
                      'Save your mood for today!',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
