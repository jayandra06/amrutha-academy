class ChatRoomModel {
  final String id;
  final String courseId;
  final String courseName;
  final String enrollmentId;
  final DateTime createdAt;
  final DateTime endDate;
  final String status; // active, read-only
  final List<String> participants;
  final String roomId; // Firebase Realtime DB path

  ChatRoomModel({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.enrollmentId,
    required this.createdAt,
    required this.endDate,
    required this.status,
    required this.participants,
    required this.roomId,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: json['id'] ?? '',
      courseId: json['courseId'] ?? '',
      courseName: json['courseName'] ?? '',
      enrollmentId: json['enrollmentId'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      endDate: DateTime.parse(json['endDate']),
      status: json['status'] ?? 'active',
      participants: List<String>.from(json['participants'] ?? []),
      roomId: json['roomId'] ?? '',
    );
  }

  bool get canSendMessages => status == 'active' && DateTime.now().isBefore(endDate);
  bool get isReadOnly => status == 'read-only' || DateTime.now().isAfter(endDate);
}




