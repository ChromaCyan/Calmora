import 'package:flutter/material.dart';

class MoodSection extends StatelessWidget {
  const MoodSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Text(
            'How are you feeling today?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
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
        ],
      ),
    );
  }
}
