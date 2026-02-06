import 'package:moong_flutter/models/chat_message.dart';

/// Repository interface for ChatMessage data operations
abstract class ChatMessageRepository {
  /// Get chat message by ID
  Future<ChatMessage?> getChatMessage(String userId, String messageId);

  /// Get all chat messages for a user and moong
  Future<List<ChatMessage>> getChatMessages(String userId, String moongId);

  /// Get recent chat messages with limit
  Future<List<ChatMessage>> getRecentChatMessages(String userId, String moongId, int limit);

  /// Get paginated chat messages
  Future<List<ChatMessage>> getChatMessagesPage(
    String userId,
    String moongId,
    int offset,
    int limit,
  );

  /// Create a new chat message
  Future<void> createChatMessage(String userId, ChatMessage message);

  /// Update an existing chat message
  Future<void> updateChatMessage(String userId, ChatMessage message);

  /// Delete a chat message
  Future<void> deleteChatMessage(String userId, String messageId);

  /// Get chat message count for a moong
  Future<int> getChatMessageCount(String userId, String moongId);

  /// Get user messages count (messages sent by user)
  Future<int> getUserMessageCount(String userId, String moongId);

  /// Get bot messages count (messages from moong)
  Future<int> getBotMessageCount(String userId, String moongId);

  /// Delete all chat messages for a moong
  Future<void> deleteChatMessagesByMoong(String userId, String moongId);

  /// Get conversation statistics (total messages, user vs bot ratio)
  Future<Map<String, int>> getConversationStats(String userId, String moongId);

  /// Search chat messages by content
  Future<List<ChatMessage>> searchChatMessages(String userId, String moongId, String query);

  /// Get latest message for a moong
  Future<ChatMessage?> getLatestMessage(String userId, String moongId);

  /// Create multiple chat messages at once (batch operation)
  Future<void> createChatMessages(String userId, List<ChatMessage> messages);
}
