import 'package:flutter/material.dart';
import 'package:armstrong/widgets/cards/appbar.dart';
import 'package:armstrong/config/colors.dart';

class JournalPage extends StatelessWidget {
  const JournalPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Log Your Mood",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: orangeContainer, 
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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

            // Mood Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                    color: orangeContainer, 
                    size: 36,
                  ),
                  onPressed: () {
                    // Placeholder Mood option
                  },
                );
              }),
            ),

            const SizedBox(height: 24),

            // Add Tags Section
            const Text(
              'Add Tags:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                _buildTagChip('Work'),
                _buildTagChip('Family'),
                _buildTagChip('Health'),
                _buildTagChip('Hobbies'),
                _buildTagChip('Friends'),
              ],
            ),

            const SizedBox(height: 24),

            // Journal Entry
            const Text(
              'Write about your day:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 6,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const TextField(
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Share your thoughts...',
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Save Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Save logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: orangeContainer, 
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save Entry',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagChip(String label) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 14)),
      backgroundColor: orangeContainer.withOpacity(0.2), 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: orangeContainer),
      ),
    );
  }
}
