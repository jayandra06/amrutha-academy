class ScheduleModel {
  final String id;
  final String courseId;
  final String trainerId;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime date;
  final String? meetingLink;
  final String status;
  final bool attendanceEnabled;

  ScheduleModel({
    required this.id,
    required this.courseId,
    required this.trainerId,
    required this.startTime,
    required this.endTime,
    required this.date,
    this.meetingLink,
    required this.status,
    required this.attendanceEnabled,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] ?? '',
      courseId: json['courseId'] ?? '',
      trainerId: json['trainerId'] ?? '',
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      date: DateTime.parse(json['date']),
      meetingLink: json['meetingLink'],
      status: json['status'] ?? 'scheduled',
      attendanceEnabled: json['attendanceEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'trainerId': trainerId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'date': date.toIso8601String(),
      'meetingLink': meetingLink,
      'status': status,
      'attendanceEnabled': attendanceEnabled,
    };
  }

  bool get isUpcoming => startTime.isAfter(DateTime.now());
  bool get isOngoing => DateTime.now().isAfter(startTime) && DateTime.now().isBefore(endTime);
  bool get isCompleted => endTime.isBefore(DateTime.now());
}




