import 'package:armstrong/patient/screens/patient_nav_home_screen.dart';
import 'package:armstrong/widgets/forms/progress_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:armstrong/widgets/forms/question_form.dart';
import 'package:armstrong/services/api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'dart:ui';
import 'package:armstrong/config/global_loader.dart';

class QuestionScreen extends StatefulWidget {
  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  PageController _pageController = PageController();
  Map<int, String> _selectedAnswers = {};
  String? _userId;
  bool _hasCompletedSurvey = false;
  List<Map<String, dynamic>> _questions = [];
  final ApiRepository _apiRepository = ApiRepository();
  bool _isLoading = true;
  String _category = '';

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _fetchQuestions();
    _checkIfSurveyCompleted();
  }

  Future<void> _loadUserId() async {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    _userId = await storage.read(key: 'userId');
  }

  Future<void> _checkIfSurveyCompleted() async {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    final hasCompletedSurvey =
        await storage.read(key: 'hasCompletedSurvey_$_userId');
    setState(() {
      _hasCompletedSurvey = hasCompletedSurvey == 'true';
    });
  }

  Future<void> _fetchQuestions() async {
    try {
      final surveys = await _apiRepository.getSurveys();
      if (surveys.isNotEmpty && surveys[0] != null) {
        final survey = surveys[0];
        _category = survey['category'] ?? 'No Category';
        _questions = List<Map<String, dynamic>>.from(survey['questions'] ?? []);
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _nextQuestion(int index) {
    if (index < _questions.length - 1) {
      _pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _submitAnswers();
    }
  }

  Future<void> _submitAnswers() async {
    List<Map<String, dynamic>> responses = [];
    final category = _category.isNotEmpty ? _category : '';

    _selectedAnswers.forEach((questionIndex, choiceId) {
      final question = _questions[questionIndex];
      final questionId = question['_id'];
      final selectedChoice = question['choices'].firstWhere(
        (choice) => choice['_id'] == choiceId,
        orElse: () => null,
      );

      if (selectedChoice != null) {
        final score = selectedChoice['score'] ?? 0;
        responses.add({
          'questionId': questionId,
          'choiceId': selectedChoice['_id'],
          'score': score
        });
      }
    });

    if (_userId == null || responses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Error!',
            message: 'Missing required data',
            contentType: ContentType.failure,
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    try {
      await _apiRepository.submitSurveyResponse(
          _userId!, _questions[0]['_id'], responses, category);

      final FlutterSecureStorage storage = FlutterSecureStorage();
      await storage.write(key: 'hasCompletedSurvey_$_userId', value: 'true');
      await storage.write(
          key: 'survey_onboarding_completed_$_userId', value: 'true');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PatientHomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Error!',
            message: 'Error submitting answers: $e',
            contentType: ContentType.failure,
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasCompletedSurvey) {
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PatientHomeScreen()),
        );
      });
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassColor =
        isDark ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.4);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "images/login_bg_image.png",
            fit: BoxFit.cover,
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
              child: Container(color: glassColor),
            ),
          ),
          _isLoading
              ? Center(
                  child: GlobalLoader.loader,
                )
              : Column(
                  children: [
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      child: Column(
                        children: [
                          SegmentedProgressBar(
                            progress: (_pageController.hasClients &&
                                    _questions.isNotEmpty)
                                ? (_pageController.page ?? 0) /
                                    (_questions.length - 1)
                                : 0,
                            segments: _questions.length,
                            filledColor: Theme.of(context).colorScheme.primary,
                            emptyColor: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.2),
                            height: 10,
                            spacing: 3,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Question ${(_pageController.hasClients ? (_pageController.page?.round() ?? 0) + 1 : 1)} / ${_questions.length}",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: PageView.builder(
                              controller: _pageController,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _questions.length,
                              itemBuilder: (context, index) {
                                final question = _questions[index];
                                final choices = question['choices'] ?? [];
                                final answers =
                                    List<Map<String, dynamic>>.from(choices);

                                return QuestionWidget(
                                  question: question['questionText'],
                                  choices: answers,
                                  selectedChoiceId:
                                      _selectedAnswers[index] ?? '',
                                  onAnswerSelected: (choiceId) {
                                    setState(() {
                                      _selectedAnswers[index] = choiceId;
                                    });
                                    Future.delayed(Duration(milliseconds: 300),
                                        () {
                                      _nextQuestion(index);
                                    });
                                  },
                                  progress: (index + 1) / _questions.length,
                                  currentQuestion: index + 1,
                                  totalQuestions: _questions.length,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .surface
                                .withOpacity(0.25),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PatientHomeScreen()),
                            );
                          },
                          child: Text(
                            "Skip for Testing purposes",
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
