import '../../../services/api_service.dart';
import '../models/api_response.dart';
import '../models/chat_room_model.dart';
import '../../core/config/di_config.dart';
import 'package:get_it/get_it.dart';

class ChatRepository {
  final ApiService _apiService = GetIt.instance<ApiService>();

  Future<List<ChatRoomModel>> getMyChatRooms() async {
    try {
      final response = await _apiService.get<List<ChatRoomModel>>(
        '/chat/rooms',
        fromJson: (json) {
          if (json is List) {
            return (json as List).map((item) => ChatRoomModel.fromJson(item as Map<String, dynamic>)).toList();
          }
          return [];
        },
      );

      if (response.isSuccess && response.data != null) {
        return response.data!;
      }
      return [];
    } catch (e) {
      print('Error fetching chat rooms: $e');
      return [];
    }
  }

  Future<ChatRoomModel?> getChatRoomById(String roomId) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/chat/rooms/$roomId/check-access',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response.isSuccess && response.data != null) {
        final roomData = response.data!['room'] as Map<String, dynamic>?;
        if (roomData != null) {
          return ChatRoomModel.fromJson(roomData);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching chat room: $e');
      return null;
    }
  }
}

