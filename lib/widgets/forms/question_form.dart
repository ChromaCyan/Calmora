import 'package:armstrong/widgets/forms/progress_bar_widget.dart';
import 'package:flutter/material.dart';

class QuestionWidget extends StatefulWidget {
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
  State<QuestionWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  bool _isQuestionHovered = false;
  String? _hoveredChoiceId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// 🟢 Hoverable Question
            MouseRegion(
              onEnter: (_) => setState(() => _isQuestionHovered = true),
              onExit: (_) => setState(() => _isQuestionHovered = false),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: theme.textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _isQuestionHovered
                      ? colorScheme.primary
                      : colorScheme.onBackground,
                ),
                child: Text(
                  widget.question,
                  textAlign: TextAlign.left,
                ),
              ),
            ),

            const SizedBox(height: 40),

            /// 🟢 Choices
            ...widget.choices.map((choice) {
              bool isSelected = widget.selectedChoiceId == choice['_id'];
              bool isHovered = _hoveredChoiceId == choice['_id'];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: MouseRegion(
                  onEnter: (_) =>
                      setState(() => _hoveredChoiceId = choice['_id']),
                  onExit: (_) => setState(() => _hoveredChoiceId = null),
                  child: GestureDetector(
                    onTap: () => widget.onAnswerSelected(choice['_id']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  colorScheme.primary.withOpacity(0.9),
                                  colorScheme.primaryContainer.withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : LinearGradient(
                                colors: isHovered
                                    ? [
                                        colorScheme.secondary.withOpacity(0.3),
                                        colorScheme.secondary.withOpacity(0.15),
                                      ]
                                    : [
                                        Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.grey[900]!
                                            : Colors.grey[200]!,
                                        Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.grey[850]!
                                            : Colors.grey[100]!,
                                      ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isSelected
                              ? colorScheme.primary
                              : (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[600]!
                                  : Colors.grey[400]!),
                          width: isSelected ? 2 : 1.2,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 1,
                              offset: Offset(0, 3),
                            ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          choice['text'],
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isSelected
                                ? colorScheme.onPrimary
                                : (isHovered
                                    ? colorScheme.primary
                                    : colorScheme.onSurface),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
