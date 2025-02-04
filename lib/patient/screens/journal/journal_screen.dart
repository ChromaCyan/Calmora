import 'package:flutter/material.dart';
import 'package:armstrong/config/colors.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/services/api.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({Key? key}) : super(key: key);

  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  String? _userId;
  int? _selectedMood; // Change from String to int (1-5)
  final TextEditingController _daySummaryController = TextEditingController();
  final ApiRepository _apiRepository = ApiRepository();

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    final userId = await storage.read(key: 'userId');
    setState(() {
      _userId = userId;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Entry'),
        backgroundColor: buttonColor,
        centerTitle: true,
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Handle mood selection (now integers from 1 to 5)
  void _onMoodSelected(int mood) {
    setState(() {
      _selectedMood = mood;
    });
  }

  // Send mood entry to backend using the method from api.dart
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
      _showSuccess(result['message']);
    } catch (e) {
      _showError('Failed to save mood entry: $e');
    }
  }

  // Show success message
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Show error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Mood selector using radio buttons (Updated to use numbers)
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

  // Radio button for each mood
  Widget _moodRadio(String label, int mood, Color color) {
    return RadioListTile<int>(
      title: Text(label),
      value: mood,
      groupValue: _selectedMood,
      onChanged: (int? selected) {
        if (selected != null) {
          _onMoodSelected(selected);
        }
      },
      secondary: CircleAvatar(
        backgroundColor: color,
        child: Text(mood.toString(), style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // Journal entry and day summary text fields
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
}
