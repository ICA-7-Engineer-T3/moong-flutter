import 'package:moong_flutter/database/chat_message_dao.dart';
import 'package:moong_flutter/models/chat_message.dart';
import 'package:moong_flutter/repositories/interfaces/chat_message_repository.dart';

/// SQLite implementation of ChatMessageRepository
/// Wraps ChatMessageDao to conform to repository interface
class ChatMessageRepositorySQLite implements ChatMessageRepository {
  final ChatMessageDao _dao = ChatMessageDao();

  @override
  Future<ChatMessage?> getChatMessage(String userId, String messageId) async {
    // Note: ChatMessageDao uses integer IDs, need to convert
    try {
      final id = int.parse(messageId);
      return await _dao.getMessage(id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<ChatMessage>> getChatMessages(String userId, String moongId) =>
      _dao.getMessagesByMoong(moongId);

  @override
  Future<List<ChatMessage>> getRecentChatMessages(String userId, String moongId, int limit) =>
      _dao.getRecentMessages(moongId, limit);

  @override
  Future<List<ChatMessage>> getChatMessagesPage(
    String userId,
    String moongId,
    int offset,
    int limit,
  ) async {
    // Note: getMessagesInRange uses DateTime, not offset
    // For now, use getRecentMessages
    return await _dao.getRecentMessages(moongId, limit);
  }

  @override
  Future<void> createChatMessage(String userId, ChatMessage message) async {
    await _dao.insertMessage(message);
  }

  @override
  Future<void> updateChatMessage(String userId, ChatMessage message) async {
    // ChatMessageDao doesn't have update method - skip for now
    // Will implement in Firestore version
  }

  @override
  Future<void> deleteChatMessage(String userId, String messageId) async {
    try {
      final id = int.parse(messageId);
      await _dao.deleteMessage(id);
    } catch (e) {
      // Ignore if not a valid integer ID
    }
  }

  @override
  Future<int> getChatMessageCount(String userId, String moongId) =>
      _dao.getMessageCount(moongId);

  @override
  Future<int> getUserMessageCount(String userId, String moongId) =>
      _dao.getUserMessageCount(moongId);

  @override
  Future<int> getBotMessageCount(String userId, String moongId) =>
      _dao.getMoongMessageCount(moongId);

  @override
  Future<void> deleteChatMessagesByMoong(String userId, String moongId) async {
    await _dao.deleteMessagesByMoong(moongId);
  }

  @override
  Future<Map<String, int>> getConversationStats(String userId, String moongId) async {
    final stats = await _dao.getConversationStats(moongId);
    return {
      'totalMessages': stats['total_messages'] as int,
      'userMessages': stats['user_messages'] as int,
      'moongMessages': stats['moong_messages'] as int,
      'todayMessages': stats['today_messages'] as int,
    };
  }

  @override
  Future<List<ChatMessage>> searchChatMessages(String userId, String moongId, String query) =>
      _dao.searchMessages(moongId, query);

  @override
  Future<ChatMessage?> getLatestMessage(String userId, String moongId) async {
    final messages = await _dao.getRecentMessages(moongId, 1);
    return messages.isEmpty ? null : messages.first;
  }

  @override
  Future<void> createChatMessages(String userId, List<ChatMessage> messages) async {
    await _dao.insertMessages(messages);
  }
}
