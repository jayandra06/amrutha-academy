class EnrollmentModel {
  final String id;
  final String userId;
  final String courseId;
  final String paymentStatus;
  final String? paymentId;
  final DateTime enrolledAt;
  final String status;
  final String? chatRoomId;

  EnrollmentModel({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.paymentStatus,
    this.paymentId,
    required this.enrolledAt,
    required this.status,
    this.chatRoomId,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    return EnrollmentModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      courseId: json['courseId'] ?? '',
      paymentStatus: json['paymentStatus'] ?? 'pending',
      paymentId: json['paymentId'],
      enrolledAt: DateTime.parse(json['enrolledAt'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'pending',
      chatRoomId: json['chatRoomId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'courseId': courseId,
      'paymentStatus': paymentStatus,
      'paymentId': paymentId,
      'enrolledAt': enrolledAt.toIso8601String(),
      'status': status,
      'chatRoomId': chatRoomId,
    };
  }

  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
}




