class AttendanceModel {
  final String id;
  final String scheduleId;
  final String userId;
  final String status; // present, absent
  final DateTime? joinedAt;
  final DateTime markedAt;

  AttendanceModel({
    required this.id,
    required this.scheduleId,
    required this.userId,
    required this.status,
    this.joinedAt,
    required this.markedAt,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] ?? '',
      scheduleId: json['scheduleId'] ?? '',
      userId: json['userId'] ?? '',
      status: json['status'] ?? 'absent',
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'])
          : null,
      markedAt: DateTime.parse(json['markedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheduleId': scheduleId,
      'userId': userId,
      'status': status,
      'joinedAt': joinedAt?.toIso8601String(),
      'markedAt': markedAt.toIso8601String(),
    };
  }
}




