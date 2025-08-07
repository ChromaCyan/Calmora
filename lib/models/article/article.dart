class Article {
  final String id;
  final String title;
  final String content;
  final String heroImage;
  final List<String> additionalImages;
  final String specialistId; 
  final List<String> categories;
  final String specialistName;
  final String targetGender;

  Article({
    required this.id,
    required this.title,
    required this.content,
    required this.heroImage,
    required this.additionalImages,
    required this.specialistId,
    required this.categories,
    required this.specialistName,
    required this.targetGender,
  });

  // Factory constructor to create an Article from a Map (API response)
  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      id: map['_id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      heroImage: map['heroImage'] ?? '',
      additionalImages: List<String>.from(map['additionalImages'] ?? []),
      specialistId: map['specialistId']?['_id'] ?? '',
      categories: List<String>.from(map['categories'] ?? []),
      specialistName: map['specialistId'] != null
          ? '${map['specialistId']['firstName'] ?? ''} ${map['specialistId']['lastName'] ?? ''}'.trim()
          : '',
      targetGender: map['targetGender'] ?? 'everyone',
    );
  }

  // Convert an Article instance to a Map (for API requests)
  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'title': title,
      'content': content,
      'heroImage': heroImage,
      'additionalImages': additionalImages,
      'specialistId': specialistId,
      'categories': categories,
      'specialistName': specialistName,
      'targetGender': targetGender,
    };
  }
}
