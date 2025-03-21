// import 'package:armstrong/patient/screens/patient_nav_home_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:armstrong/widgets/forms/question_form.dart';
// import 'package:armstrong/services/api.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

// class QuestionScreen extends StatefulWidget {
//   @override
//   _QuestionScreenState createState() => _QuestionScreenState();
// }

// class _QuestionScreenState extends State<QuestionScreen> {
//   PageController _pageController = PageController();
//   Map<int, String> _selectedAnswers = {};
//   String? _userId;
//   bool _hasCompletedSurvey = false;
//   List<Map<String, dynamic>> _questions = [];
//   final ApiRepository _apiRepository = ApiRepository();
//   bool _isLoading = true;
//   String _category = '';

//   @override
//   void initState() {
//     super.initState();
//     _loadUserId();
//     _fetchQuestions();
//     _checkIfSurveyCompleted();
//   }

//   Future<void> _loadUserId() async {
//     final FlutterSecureStorage storage = FlutterSecureStorage();
//     _userId = await storage.read(key: 'userId');
//   }

//   Future<void> _checkIfSurveyCompleted() async {
//     final FlutterSecureStorage storage = FlutterSecureStorage();
//     final hasCompletedSurvey =
//         await storage.read(key: 'hasCompletedSurvey_$_userId');
//     setState(() {
//       _hasCompletedSurvey = hasCompletedSurvey == 'true';
//     });
//   }

//   Future<void> _fetchQuestions() async {
//     try {
//       final surveys = await _apiRepository.getSurveys();
//       if (surveys.isNotEmpty) {
//         final survey = surveys[0];
//         _category = survey.category;
//         _questions = survey.questions.map((question) {
//           return {
//             '_id': question.id,
//             'questionText': question.questionText,
//             'choices': question.choices.map((choice) {
//               return {
//                 '_id': choice.id,
//                 'text': choice.choiceText,
//                 'score': choice.score,
//               };
//             }).toList(),
//           };
//         }).toList();

//         setState(() {
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _nextQuestion(int index) {
//     if (index < _questions.length - 1) {
//       _pageController.nextPage(
//           duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
//     } else {
//       _submitAnswers();
//     }
//   }

//   Future<void> _submitAnswers() async {
//     List<Map<String, dynamic>> responses = [];
//     final category = _category.isNotEmpty ? _category : '';

//     _selectedAnswers.forEach((questionIndex, choiceId) {
//       final question = _questions[questionIndex];
//       final questionId = question['_id'];
//       final selectedChoice = question['choices'].firstWhere(
//         (choice) => choice['_id'] == choiceId,
//         orElse: () => null,
//       );

//       if (selectedChoice != null) {
//         final score = selectedChoice['score'] ?? 0;
//         responses.add({
//           'questionId': questionId,
//           'choiceId': selectedChoice['_id'],
//           'score': score
//         });
//       }
//     });

//     if (_userId == null || responses.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           elevation: 0,
//           behavior: SnackBarBehavior.floating,
//           backgroundColor: Colors.transparent,
//           content: AwesomeSnackbarContent(
//             title: 'Error!',
//             message: 'Missing required data',
//             contentType: ContentType.failure,
//           ),
//           duration: const Duration(seconds: 3),
//         ),
//       );
//       return;
//     }

//     try {
//       await _apiRepository.submitSurveyResponse(
//           _userId!, _questions[0]['_id'], responses, category);

//       // Save completion flag
//       final FlutterSecureStorage storage = FlutterSecureStorage();
//       await storage.write(key: 'hasCompletedSurvey_$_userId', value: 'true');
//       await storage.write(
//           key: 'survey_onboarding_completed_$_userId', value: 'true');

//       // Navigate to home screen after survey completion
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => PatientHomeScreen()),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           elevation: 0,
//           behavior: SnackBarBehavior.floating,
//           backgroundColor: Colors.transparent,
//           content: AwesomeSnackbarContent(
//             title: 'Error!',
//             message: 'Error submitting answers: $e',
//             contentType: ContentType.failure,
//           ),
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_hasCompletedSurvey) {
//       Future.delayed(Duration(seconds: 1), () {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => PatientHomeScreen()),
//         );
//       });
//     }

//     return Scaffold(
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Align(
//                     alignment: Alignment.topRight,
//                     child: TextButton(
//                       onPressed: () {
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => PatientHomeScreen()),
//                         );
//                       },
//                       child: Text(
//                         "Skip for Testing purposes",
//                         style: TextStyle(fontSize: 16, color: Colors.blue),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: PageView.builder(
//                     controller: _pageController,
//                     physics: NeverScrollableScrollPhysics(),
//                     itemCount: _questions.length,
//                     itemBuilder: (context, index) {
//                       final question = _questions[index];
//                       final choices = question['choices'] ?? [];
//                       final answers = List<Map<String, dynamic>>.from(choices);

//                       return QuestionWidget(
//                         question: question['questionText'],
//                         choices: answers,
//                         selectedChoiceId: _selectedAnswers[index] ?? '',
//                         onAnswerSelected: (choiceId) {
//                           setState(() {
//                             _selectedAnswers[index] = choiceId;
//                           });
//                           Future.delayed(Duration(milliseconds: 300), () {
//                             _nextQuestion(index);
//                           });
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }

import 'package:armstrong/patient/screens/patient_nav_home_screen.dart';
import 'package:armstrong/widgets/navigation/appbar.dart';
import 'package:flutter/material.dart';
import 'package:armstrong/widgets/forms/question_form.dart';
import 'package:armstrong/patient/screens/survey/submission_page.dart';
import 'package:armstrong/services/api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

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

      // Save completion flag
      final FlutterSecureStorage storage = FlutterSecureStorage();
      await storage.write(key: 'hasCompletedSurvey_$_userId', value: 'true');
      await storage.write(
          key: 'survey_onboarding_completed_$_userId', value: 'true');

      // Navigate to home screen after survey completion
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

    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _questions.length,
                    itemBuilder: (context, index) {
                      final question = _questions[index];
                      final choices = question['choices'] ?? [];
                      final answers = List<Map<String, dynamic>>.from(choices);

                      double progress = (index + 1) / 20; // Calculate progress

                      return QuestionWidget(
                        question: question['questionText'],
                        choices: answers,
                        selectedChoiceId: _selectedAnswers[index] ?? '',
                        onAnswerSelected: (choiceId) {
                          setState(() {
                            _selectedAnswers[index] = choiceId;
                          });
                          Future.delayed(Duration(milliseconds: 300), () {
                            _nextQuestion(index);
                          });
                        },
                        progress: progress,
                        currentQuestion: index + 1,
                        totalQuestions: _questions.length,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}