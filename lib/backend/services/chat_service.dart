import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/messenger/models/chat_state.dart';
import '../../features/profile/models/profile_state.dart';
import 'notification_service.dart';

class ChatService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Track the active room ID the user is currently viewing to avoid marking incoming messages as unread
  static String? activeRoomId;

  // Fetch available rooms and their latest message previews
  static Future<List<ChatRoom>> fetchRooms() async {
    isLoadingChatRooms.value = true;
    try {
      final response = await _client.from('chat_rooms').select();
      final rooms = (response as List)
          .map((row) => ChatRoom.fromJson(row))
          .toList();
      chatRoomsList.value = rooms;

      // Fetch the latest messages for all rooms to populate list previews
      final userId = _client.auth.currentUser?.id ?? '';
      if (userId.isNotEmpty && rooms.isNotEmpty) {
        try {
          final lastMessagesResponse = await _client
              .from('messages')
              .select()
              .order('created_at', ascending: false);
          
          final Map<String, ChatMessage> lastMessagesMap = {};
          for (var m in lastMessagesResponse) {
            final msg = ChatMessage.fromJson(m, userId);
            lastMessagesMap.putIfAbsent(msg.roomId, () => msg);
          }
          chatRoomLastMessages.value = lastMessagesMap;
        } catch (e) {
          // Silently ignore preview load errors
        }
      }

      return rooms;
    } catch (e) {
      rethrow;
    } finally {
      isLoadingChatRooms.value = false;
    }
  }

  // Send a message and return the created object
  static Future<ChatMessage?> sendMessage(String roomId, String text) async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final profile = currentProfile.value;

    final response = await _client.from('messages').insert({
      'room_id': roomId,
      'sender_id': user.id,
      'sender_name': profile.name.isEmpty ? 'Member' : profile.name,
      'sender_image': profile.imagePath, 
      'text': text,
    }).select().single();

    final sentMsg = ChatMessage.fromJson(response, user.id);

    // Instantly update the last message preview locally for immediate UI updates
    final currentPrevs = Map<String, ChatMessage>.from(chatRoomLastMessages.value);
    currentPrevs[roomId] = sentMsg;
    chatRoomLastMessages.value = currentPrevs;

    return sentMsg;
  }

  // Subscribe to real-time messages for a room
  static RealtimeChannel subscribeToRoom(String roomId, Function(ChatMessage) onMessage) {
    final userId = _client.auth.currentUser?.id ?? '';
    
    return _client
        .channel('room_$roomId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: roomId,
          ),
          callback: (payload) {
            final newMessage = ChatMessage.fromJson(payload.newRecord, userId);

            // Update real-time previews for list views
            final currentPrevs = Map<String, ChatMessage>.from(chatRoomLastMessages.value);
            currentPrevs[roomId] = newMessage;
            chatRoomLastMessages.value = currentPrevs;

            onMessage(newMessage);
          },
        )
        .subscribe();
  }

  // Fetch message history
  static Future<List<ChatMessage>> fetchMessageHistory(String roomId) async {
    final userId = _client.auth.currentUser?.id ?? '';
    try {
      final response = await _client
          .from('messages')
          .select()
          .eq('room_id', roomId)
          .order('created_at', ascending: true);
      
      return (response as List)
          .map((row) => ChatMessage.fromJson(row, userId))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static RealtimeChannel? _globalMessagesChannel;

  // Global subscription for background notifications and unread tracking
  static void subscribeToAllMessages() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    if (_globalMessagesChannel != null) return;

    _globalMessagesChannel = _client
      .channel('global_messages')
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'messages',
        callback: (payload) {
          final data = payload.newRecord;
          final roomId = data['room_id'] ?? '';
          final newMessage = ChatMessage.fromJson(data, userId);

          // Update last message preview in real-time
          final currentPrevs = Map<String, ChatMessage>.from(chatRoomLastMessages.value);
          currentPrevs[roomId] = newMessage;
          chatRoomLastMessages.value = currentPrevs;

          if (data['sender_id'] != userId) {
            // ONLY increment unreads if the user is NOT inside this active chat room!
            if (activeRoomId != roomId) {
              final currentUnreads = Map<String, int>.from(chatRoomUnreadCounts.value);
              currentUnreads[roomId] = (currentUnreads[roomId] ?? 0) + 1;
              chatRoomUnreadCounts.value = currentUnreads;

              final room = chatRoomsList.value.firstWhere(
                (r) => r.id == roomId,
                orElse: () => ChatRoom(
                  id: '', 
                  name: 'Group', 
                  description: '', 
                  type: ChatRoomType.general,
                  iconKey: 'groups',
                  createdAt: DateTime.now(),
                ),
              );

              NotificationService.incrementUnread('messenger');
              NotificationService.showNotification(
                id: 4,
                title: '${data['sender_name']} (${room.name})',
                body: data['text'] ?? 'Sent a message',
              );
            }
          }
        },
      );
    
    _globalMessagesChannel!.subscribe();
  }

  static Future<void> unsubscribeFromMessages() async {
    if (_globalMessagesChannel != null) {
      try {
        await _client.removeChannel(_globalMessagesChannel!);
      } catch (e) {
        // Silently ignore
      }
      _globalMessagesChannel = null;
    }
  }
}
