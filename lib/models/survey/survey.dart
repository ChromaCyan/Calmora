class Survey {
  final String id;
  final String category;
  final List<Question> questions;

  Survey({
    required this.id,
    required this.category,
    required this.questions,
  });

  factory Survey.fromJson(Map<String, dynamic> json) {
    var questionsList = (json['questions'] as List)
        .map((questionJson) => Question.fromJson(questionJson))
        .toList();
    return Survey(
      id: json['_id'],
      category: json['category'] ?? '',
      questions: questionsList,
    );
  }
}

class Question {
  final String id;
  final String questionText;
  final List<Choice> choices;

  Question({
    required this.id,
    required this.questionText,
    required this.choices,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    var choicesList = (json['choices'] as List)
        .map((choiceJson) => Choice.fromJson(choiceJson))
        .toList();
    return Question(
      id: json['_id'],
      questionText: json['questionText'],
      choices: choicesList,
    );
  }
}

class Choice {
  final String id;
  final String choiceText;
  final int score;

  Choice({
    required this.id,
    required this.choiceText,
    required this.score,
  });

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      id: json['_id'],
      choiceText: json['text'], 
      score: json['score'] ?? 0,
    );
  }
}
