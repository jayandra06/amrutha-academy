import '../../core/config/firebase_config.dart';
import '../models/chat_room_model.dart';

class ChatRepository {
  Future<List<ChatRoomModel>> getMyChatRooms() async {
    try {
      if (FirebaseConfig.firestore == null) {
        return [];
      }

      final currentUser = FirebaseConfig.auth?.currentUser;
      if (currentUser == null) {
        return [];
      }

      // Get chat rooms where user is a participant
      final snapshot = await FirebaseConfig.firestore!
          .collection('chatRooms')
          .where('participants', arrayContains: currentUser.uid)
          .get();

      return snapshot.docs
          .map((doc) {
            try {
              return ChatRoomModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              });
            } catch (e) {
              print('Error parsing chat room ${doc.id}: $e');
              return null;
            }
          })
          .whereType<ChatRoomModel>()
          .toList();
    } catch (e) {
      print('Error fetching chat rooms: $e');
      return [];
    }
  }

  Future<ChatRoomModel?> getChatRoomById(String roomId) async {
    try {
      if (FirebaseConfig.firestore == null) {
        return null;
      }

      final currentUser = FirebaseConfig.auth?.currentUser;
      if (currentUser == null) {
        return null;
      }

      final doc = await FirebaseConfig.firestore!
          .collection('chatRooms')
          .doc(roomId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        // Check if user has access (is a participant)
        final participants = List<String>.from(data['participants'] ?? []);
        if (participants.contains(currentUser.uid)) {
          return ChatRoomModel.fromJson({
            'id': doc.id,
            ...data,
          });
        }
      }
      return null;
    } catch (e) {
      print('Error fetching chat room: $e');
      return null;
    }
  }
}
