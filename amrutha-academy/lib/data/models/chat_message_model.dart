class ChatMessageModel {
  final String id;
  final String roomId;
  final String userId;
  final String userName;
  final String message;
  final DateTime timestamp;
  final String? type; // text, system

  ChatMessageModel({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.userName,
    required this.message,
    required this.timestamp,
    this.type = 'text',
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] ?? '',
      roomId: json['roomId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'])
          : DateTime.now(),
      type: json['type'] ?? 'text',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'userId': userId,
      'userName': userName,
      'message': message,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'type': type ?? 'text',
    };
  }
}




