class GeminiResponse {
  final String reply;
  final String? audio;

  GeminiResponse({required this.reply, this.audio});

  factory GeminiResponse.fromJson(Map<String, dynamic> json) {
    return GeminiResponse(
      reply: json['reply'],
      audio: json['audio'],
    );
  }
}
