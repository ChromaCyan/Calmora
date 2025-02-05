class Choice {
  final String text;
  final int score;
  final String id;

  Choice({required this.text, required this.score, required this.id});

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      text: json['text'],
      score: json['score'],
      id: json['_id'],
    );
  }
}

class Question {
  final String questionText;
  final List<Choice> choices;
  final String id;

  Question({required this.questionText, required this.choices, required this.id});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      questionText: json['questionText'],
      choices: (json['choices'] as List).map((choice) => Choice.fromJson(choice)).toList(),
      id: json['_id'],
    );
  }
}

class SurveyResponse {
  final String category;
  final List<Question> questions;

  SurveyResponse({required this.category, required this.questions});

  factory SurveyResponse.fromJson(Map<String, dynamic> json) {
    return SurveyResponse(
      category: json['category'],
      questions: (json['questions'] as List).map((q) => Question.fromJson(q)).toList(),
    );
  }
}
