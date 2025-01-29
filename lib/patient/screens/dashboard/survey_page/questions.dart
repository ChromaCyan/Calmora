import 'package:flutter/material.dart';
import 'package:armstrong/patient/screens/dashboard/survey_page/question_page.dart'; // Import the new widget
import 'package:armstrong/patient/screens/dashboard/survey_page/submission_page.dart';

class QuestionScreen extends StatefulWidget {
  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  PageController _pageController = PageController();
  Map<int, int> _selectedAnswers = {};

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'How satisfied are you with your life right now?',
      'answers': [
        'Strongly Disagree',
        'Somewhat Disagree',
        'Neither Agree nor Disagree',
        'Somewhat Agree',
        'Strongly Agree'
      ]
    },
    {
      'question': 'How often do you feel positive emotions?',
      'answers': [
        'Strongly Disagree',
        'Somewhat Disagree',
        'Neither Agree nor Disagree',
        'Somewhat Agree',
        'Strongly Agree'
      ]
    },
    {
      'question': 'How often do you feel motivated to pursue your goals?',
      'answers': [
        'Strongly Disagree',
        'Somewhat Disagree',
        'Neither Agree nor Disagree',
        'Somewhat Agree',
        'Strongly Agree'
      ]
    },
    {
      'question': 'Do you feel comfortable expressing your emotions to others?',
      'answers': [
        'Strongly Disagree',
        'Somewhat Disagree',
        'Neither Agree nor Disagree',
        'Somewhat Agree',
        'Strongly Agree'
      ]
    },
    {
      'question': 'How often do you find yourself feeling hopeless or down?',
      'answers': [
        'I often feel hopeless',
        'I sometimes feel hopeless',
        'Neutral',
        'I rarely feel hopeless',
        'I never feel hopeless'
      ]
    },
    {
      'question': 'How often do you seek social interaction with friends or family?',
      'answers': [
        'Rarely',
        'Occasionally',
        'Often but not frequently',
        'Frequently but not daily',
        'Daily'
      ]
    },
    {
      'question': 'Are you able to concentrate and focus on tasks without difficulty?',
      'answers': [
        'Not at all',
        'A little bit',
        'Neutral/most times yes but occasionally no',
        'Mostly/yes, usually can focus without issue but rare occasion when can\'t',
        'Completely Able/Always can focus on tasks without any issue'
      ]
    },
    {
      'question': 'Do you feel comfortable reaching out for help when you need it?',
      'answers': [
        'Uncomfortable reaching out',
        'Slightly uncomfortable',
        'Neutral',
        'Moderately Comfortable',
        'Very Comfortable'
      ]
    },
    {
      'question': 'Do you find it easy to relax and unwind after a stressful day?',
      'answers': [
        'Extremely difficult',
        'Difficult',
        'Average ease',
        'Easy',
        'Very Easy'
      ]
    },
    {
      'question': 'How often do you feel pressured to conform to traditional masculine norms? (Reverse scored)',
      'answers': [
        'Never Pressured /(does NOT describe me)',
        'Occasionally Pressured /(somewhat untrue)',
        'Partial Truth /(Neutral)',
        'Usually Pressured/(fairly true)',
        'Always Pressured/(describes me PERFECTLY)'
      ]
    },
  ];

  void _nextQuestion(int index) {
    if (index < _questions.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SubmissionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Questionnaire'),
        backgroundColor: Color(0xFF81C784),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: _questions.length,
        itemBuilder: (context, index) {
          return QuestionWidget(
            question: _questions[index]['question'],
            answers: List<String>.from(_questions[index]['answers']),
            selectedAnswerIndex: _selectedAnswers[index] ?? -1,
            onAnswerSelected: (answerIndex) {
              setState(() {
                _selectedAnswers[index] = answerIndex;
              });
              Future.delayed(Duration(milliseconds: 300), () {
                _nextQuestion(index);
              });
            },
          );
        },
      ),
    );
  }
}