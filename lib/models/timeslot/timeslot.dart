class TimeSlotModel {
  final String id;
  final String specialist;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final bool isBooked;

  TimeSlotModel({
    required this.id,
    required this.specialist,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isBooked,
  });

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotModel(
      id: json['_id'],
      specialist: json['specialist'],
      dayOfWeek: json['dayOfWeek'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      isBooked: json['isBooked'] ?? false,
    );
  }
}
