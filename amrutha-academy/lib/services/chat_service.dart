import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/chat_message_model.dart';
import '../../core/config/firebase_config.dart';

class ChatService {
  DatabaseReference get _database => FirebaseConfig.databaseRef;

  Stream<List<ChatMessageModel>> getMessagesStream(String roomPath) {
    return _database
        .child(roomPath)
        .child('messages')
        .orderByChild('timestamp')
        .onValue
        .map((event) {
      if (event.snapshot.value == null) {
        return <ChatMessageModel>[];
      }

      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final messages = <ChatMessageModel>[];

      data.forEach((key, value) {
        if (value is Map) {
          messages.add(ChatMessageModel.fromJson({
            'id': key,
            ...Map<String, dynamic>.from(value),
          }));
        }
      });

      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return messages;
    });
  }

  Future<void> sendMessage(
    String roomPath,
    String userId,
    String userName,
    String message,
  ) async {
    if (message.trim().isEmpty) return;

    // Filter out phone numbers and emails from messages
    final filteredMessage = _filterContactInfo(message);

    final messageRef = _database.child(roomPath).child('messages').push();
    await messageRef.set({
      'userId': userId,
      'userName': userName,
      'message': filteredMessage,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'type': 'text',
    });
  }

  String _filterContactInfo(String message) {
    // Remove phone numbers (10+ digits)
    String filtered = message.replaceAll(RegExp(r'\b\d{10,}\b'), '[Phone number hidden]');
    
    // Remove email addresses
    filtered = filtered.replaceAll(
      RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'),
      '[Email hidden]',
    );

    return filtered;
  }
}

