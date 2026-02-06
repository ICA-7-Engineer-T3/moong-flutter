import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moong_flutter/models/chat_message.dart';
import 'package:moong_flutter/repositories/interfaces/chat_message_repository.dart';

/// Firestore implementation of ChatMessageRepository
class ChatMessageRepositoryFirestore implements ChatMessageRepository {
  final FirebaseFirestore _firestore;
  static const String _usersCollection = 'users';
  static const String _chatMessagesSubcollection = 'chatMessages';

  ChatMessageRepositoryFirestore({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _chatMessagesCollection(String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_chatMessagesSubcollection);
  }

  @override
  Future<ChatMessage?> getChatMessage(String userId, String messageId) async {
    try {
      final doc = await _chatMessagesCollection(userId).doc(messageId).get();
      if (!doc.exists) return null;
      return ChatMessage.fromFirestore(doc, userId);
    } catch (e) {
      throw Exception('Failed to get chat message: $e');
    }
  }

  @override
  Future<List<ChatMessage>> getChatMessages(String userId, String moongId) async {
    try {
      final snapshot = await _chatMessagesCollection(userId)
          .where('moongId', isEqualTo: moongId)
          .orderBy('createdAt', descending: false)
          .get();
      return snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc, userId))
          .toList();
    } catch (e) {
      throw Exception('Failed to get chat messages: $e');
    }
  }

  @override
  Future<List<ChatMessage>> getRecentChatMessages(
      String userId, String moongId, int limit) async {
    try {
      final snapshot = await _chatMessagesCollection(userId)
          .where('moongId', isEqualTo: moongId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      final messages = snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc, userId))
          .toList();
      return messages.reversed.toList();
    } catch (e) {
      throw Exception('Failed to get recent chat messages: $e');
    }
  }

  @override
  Future<List<ChatMessage>> getChatMessagesPage(
      String userId, String moongId, int offset, int limit) async {
    try {
      final snapshot = await _chatMessagesCollection(userId)
          .where('moongId', isEqualTo: moongId)
          .orderBy('createdAt', descending: false)
          .get();

      final allMessages = snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc, userId))
          .toList();

      if (offset >= allMessages.length) return [];
      final endIndex = (offset + limit).clamp(0, allMessages.length);
      return allMessages.sublist(offset, endIndex);
    } catch (e) {
      throw Exception('Failed to get chat messages page: $e');
    }
  }

  @override
  Future<void> createChatMessage(String userId, ChatMessage message) async {
    try {
      final docRef = message.firestoreId != null
          ? _chatMessagesCollection(userId).doc(message.firestoreId)
          : _chatMessagesCollection(userId).doc();

      await docRef.set(message.toFirestore());
    } catch (e) {
      throw Exception('Failed to create chat message: $e');
    }
  }

  @override
  Future<void> updateChatMessage(String userId, ChatMessage message) async {
    try {
      if (message.firestoreId == null) {
        throw Exception('Cannot update chat message without firestoreId');
      }
      await _chatMessagesCollection(userId)
          .doc(message.firestoreId)
          .update(message.toFirestore());
    } catch (e) {
      throw Exception('Failed to update chat message: $e');
    }
  }

  @override
  Future<void> deleteChatMessage(String userId, String messageId) async {
    try {
      await _chatMessagesCollection(userId).doc(messageId).delete();
    } catch (e) {
      throw Exception('Failed to delete chat message: $e');
    }
  }

  @override
  Future<int> getChatMessageCount(String userId, String moongId) async {
    try {
      final snapshot = await _chatMessagesCollection(userId)
          .where('moongId', isEqualTo: moongId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get chat message count: $e');
    }
  }

  @override
  Future<int> getUserMessageCount(String userId, String moongId) async {
    try {
      final snapshot = await _chatMessagesCollection(userId)
          .where('moongId', isEqualTo: moongId)
          .where('isUser', isEqualTo: true)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get user message count: $e');
    }
  }

  @override
  Future<int> getBotMessageCount(String userId, String moongId) async {
    try {
      final snapshot = await _chatMessagesCollection(userId)
          .where('moongId', isEqualTo: moongId)
          .where('isUser', isEqualTo: false)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get bot message count: $e');
    }
  }

  @override
  Future<void> deleteChatMessagesByMoong(String userId, String moongId) async {
    try {
      final snapshot = await _chatMessagesCollection(userId)
          .where('moongId', isEqualTo: moongId)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete chat messages by moong: $e');
    }
  }

  @override
  Future<Map<String, int>> getConversationStats(String userId, String moongId) async {
    try {
      final snapshot = await _chatMessagesCollection(userId)
          .where('moongId', isEqualTo: moongId)
          .get();

      int totalMessages = snapshot.docs.length;
      int userMessages = 0;
      int botMessages = 0;

      for (final doc in snapshot.docs) {
        final isUser = doc.data()['isUser'] as bool;
        if (isUser) {
          userMessages++;
        } else {
          botMessages++;
        }
      }

      return {
        'total': totalMessages,
        'user': userMessages,
        'bot': botMessages,
      };
    } catch (e) {
      throw Exception('Failed to get conversation stats: $e');
    }
  }

  @override
  Future<List<ChatMessage>> searchChatMessages(
      String userId, String moongId, String query) async {
    try {
      final snapshot = await _chatMessagesCollection(userId)
          .where('moongId', isEqualTo: moongId)
          .orderBy('createdAt', descending: false)
          .get();

      final queryLower = query.toLowerCase();
      return snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc, userId))
          .where((msg) => msg.message.toLowerCase().contains(queryLower))
          .toList();
    } catch (e) {
      throw Exception('Failed to search chat messages: $e');
    }
  }

  @override
  Future<ChatMessage?> getLatestMessage(String userId, String moongId) async {
    try {
      final snapshot = await _chatMessagesCollection(userId)
          .where('moongId', isEqualTo: moongId)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return ChatMessage.fromFirestore(snapshot.docs.first, userId);
    } catch (e) {
      throw Exception('Failed to get latest message: $e');
    }
  }

  @override
  Future<void> createChatMessages(String userId, List<ChatMessage> messages) async {
    try {
      final batch = _firestore.batch();
      for (final message in messages) {
        final docRef = message.firestoreId != null
            ? _chatMessagesCollection(userId).doc(message.firestoreId)
            : _chatMessagesCollection(userId).doc();
        batch.set(docRef, message.toFirestore());
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to create chat messages batch: $e');
    }
  }
}
