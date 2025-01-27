import 'package:flutter/material.dart';
import 'package:armstrong/widgets/cards/appbar.dart';

class JournalPage extends StatelessWidget {
  const JournalPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Log Your Mood",
        hasBackButton: true,
        onBackButtonPressed: () {
          Navigator.of(context).pop();
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How are you feeling today?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Mood Selection (e.g., Emoji-like icons)
            Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index == 0
                      ? Icons.sentiment_very_dissatisfied
                      : index == 1
                          ? Icons.sentiment_dissatisfied
                          : index == 2
                              ? Icons.sentiment_neutral
                              : index == 3
                                  ? Icons.sentiment_satisfied
                                  : Icons.sentiment_very_satisfied,
                  color: Colors.orange,
                ),
                onPressed: () {
                  // Placeholder Mood option (No backend yet)
                },
              );
            }),
          ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: const [
            //     Icon(Icons.sentiment_very_satisfied, size: 40, color: Colors.green),
            //     Icon(Icons.sentiment_satisfied, size: 40, color: Colors.lightGreen),
            //     Icon(Icons.sentiment_neutral, size: 40, color: Colors.yellow),
            //     Icon(Icons.sentiment_dissatisfied, size: 40, color: Colors.orange),
            //     Icon(Icons.sentiment_very_dissatisfied, size: 40, color: Colors.red),
            //   ],
            // ),
            const SizedBox(height: 24),
            const Text(
              'Add Tags:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Wrap(
            //   spacing: 8,
            //   children: [
            //     Chip(label: Text('Work')),
            //     Chip(label: Text('Family')),
            //     Chip(label: Text('Health')),
            //     Chip(label: Text('Hobbies')),
            //     Chip(label: Text('Friends')),
            //   ],
            // ),
            const SizedBox(height: 24),
            const Text(
              'Write about your day:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const TextField(
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Share your thoughts...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Logic to save or process the mood log
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
