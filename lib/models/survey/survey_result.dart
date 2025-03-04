class SurveyResult {
  final int totalScore;
  final String interpretation;

  SurveyResult({required this.totalScore, required this.interpretation});

  factory SurveyResult.fromJson(Map<String, dynamic> json) {
    return SurveyResult(
      totalScore: json['totalScore'] ?? 0,
      interpretation: json['interpretation'] ?? 'No Data',
    );
  }
}
