import 'package:flutter/material.dart';

class QuestionWidget extends StatelessWidget {
  final String question;
  final List<Map<String, dynamic>> choices;
  final String selectedChoiceId;
  final ValueChanged<String> onAnswerSelected;
  final double progress; // Progress percentage (0.0 - 1.0)
  final int currentQuestion; // Current question number
  final int totalQuestions; // Total number of questions

  const QuestionWidget({
    Key? key,
    required this.question,
    required this.choices,
    required this.selectedChoiceId,
    required this.onAnswerSelected,
    required this.progress,
    required this.currentQuestion,
    required this.totalQuestions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            question,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 20),
          ...choices.map((choice) {
            bool isSelected = selectedChoiceId == choice['_id'];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: GestureDetector(
                onTap: () => onAnswerSelected(choice['_id']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [colorScheme.primary, colorScheme.primaryContainer],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [colorScheme.surface, colorScheme.surface],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.withOpacity(0.6)
                            : Colors.black.withOpacity(0.12),
                        blurRadius: 5,
                        spreadRadius: 2,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      choice['text'],
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 20),

          /// **Progress Bar**
          Column(
            children: [
              /// **Rounded Progress Bar**
              ClipRRect(
                borderRadius: BorderRadius.circular(10), // Apply border radius
                child: LinearProgressIndicator(
                  value: progress, // Progress value (0.0 - 1.0)
                  backgroundColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800] // Dark grey in dark mode
                      : Colors.grey[300], // Light grey in light mode
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                  minHeight: 8, // Set height for better visibility
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Question: $currentQuestion / $totalQuestions", // Show current question number
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
