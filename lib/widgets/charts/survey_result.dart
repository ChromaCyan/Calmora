import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/services/api.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:armstrong/models/survey/survey_result.dart';
import 'package:armstrong/config/global_loader.dart';

class SurveyScoreChart extends StatefulWidget {
  final String patientId;

  const SurveyScoreChart({Key? key, required this.patientId}) : super(key: key);

  @override
  _SurveyScoreChartState createState() => _SurveyScoreChartState();
}

class _SurveyScoreChartState extends State<SurveyScoreChart> {
  final _storage = const FlutterSecureStorage();
  final ApiRepository _apiRepository = ApiRepository();
  late Future<SurveyResult> surveyData;

  @override
  void initState() {
    super.initState();
    surveyData = fetchSurveyData(widget.patientId);
  }

  Future<SurveyResult> fetchSurveyData(String patientId) async {
    try {
      return await _apiRepository.getPatientSurveyResults(patientId);
    } catch (e) {
      return SurveyResult(totalScore: 0, interpretation: 'No Data');
    }
  }

  Map<String, dynamic> getInterpretation(int score, ColorScheme colorScheme) {
    if (score >= 30) {
      return {
        'title': "You're in a Good Space 💚",
        'message':
            "You seem to be feeling quite balanced and in touch with yourself. "
                "Keep nurturing that mindset — we’ll recommend resources to help you maintain your wellbeing.",
        'color': Colors.green
      };
    } else if (score >= 22 && score < 30) {
      return {
        'title': "You're Managing Things Well 🌼",
        'message':
            "It looks like you might be juggling a few thoughts or emotions lately — and that’s okay. "
                "Our articles and guides will help you stay centered and take care of your peace of mind.",
        'color': Colors.orange
      };
    } else if (score >= 15 && score < 22) {
      return {
        'title': "You Might Be Going Through a Lot 💜",
        'message': "Things may feel heavy at times, and that’s completely valid. "
            "You’re not alone — we’ll recommend resources and self-help tools that can support you day by day.",
        'color': Colors.purple
      };
    } else {
      return {
        'title': "It Seems You're Having a Hard Time ❤️",
        'message': "You might be facing something challenging right now. "
            "That’s okay — reaching out and getting support is a strong step. "
            "We’ll guide you with helpful tools and options to talk to someone who can help.",
        'color': Colors.red
      };
    }
  }

  Widget buildEmoteIcon(String title, Color color) {
    IconData iconData;

    if (title.contains("Good Space")) {
      iconData = LucideIcons.smile;
    } else if (title.contains("Managing")) {
      iconData = LucideIcons.smilePlus;
    } else if (title.contains("Going Through")) {
      iconData = LucideIcons.meh;
    } else if (title.contains("Hard Time")) {
      iconData = LucideIcons.frown;
    } else {
      iconData = LucideIcons.helpCircle;
    }

    return Icon(iconData, color: color, size: 80);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FutureBuilder<SurveyResult>(
      future: surveyData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return GlobalLoader.loader;
        } else if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Text(
              "No survey results found.",
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.error),
            ),
          );
        }

        final surveyResult = snapshot.data!;
        final int score = surveyResult.totalScore;
        final interpretationData = getInterpretation(score, colorScheme);

        return Card(
          elevation: 0,
          color: colorScheme.surface.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.scrollText,
                        color: colorScheme.primary, size: 26),
                    const SizedBox(width: 8),
                    Text(
                      "Survey Score",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "$score / 35",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  interpretationData['title'],
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: interpretationData['color'],
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  interpretationData['message'],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.8),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                buildEmoteIcon(
                    interpretationData['title'], interpretationData['color']),
                const SizedBox(height: 10),
                Text(
                  "$score / 35",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
