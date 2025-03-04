class NotificationModel {
  final String id;
  final String message;
  final bool isRead;
  final DateTime timestamp;

  NotificationModel({
    required this.id,
    required this.message,
    required this.isRead,
    required this.timestamp,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['_id'] ?? '',
      message: map['message'] ?? '',
      isRead: map['isRead'] ?? false,
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'message': message,
      'isRead': isRead,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
