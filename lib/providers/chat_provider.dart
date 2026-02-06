import 'dart:math';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../database/chat_message_dao.dart';

class ChatProvider with ChangeNotifier {
  final ChatMessageDao _chatMessageDao = ChatMessageDao();
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _userId;
  String? _moongId;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  static const List<String> _responses = [
    '그렇구나! 네 이야기를 듣고 있어',
    '정말 그랬구나. 너무 수고했어',
    '나도 같은 마음이야. 함께 있어줄게',
    '이해해. 언제든 이야기해줘',
    '잘했어! 너는 대단해',
  ];

  Future<void> initialize(String userId, String moongId) async {
    _userId = userId;
    _moongId = moongId;

    if (kIsWeb) {
      debugPrint('Web platform - skipping chat database operations');
      _isLoading = false;
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final recentMessages = await _chatMessageDao.getRecentMessages(
        moongId,
        50,
      );
      _messages = List<ChatMessage>.from(recentMessages);
    } catch (e) {
      debugPrint('Error loading chat messages: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text) async {
    if (_userId == null || _moongId == null) {
      debugPrint('ChatProvider not initialized: userId or moongId is null');
      return;
    }

    final userMessage = ChatMessage(
      userId: _userId!,
      moongId: _moongId!,
      message: text,
      isUser: true,
    );

    if (!kIsWeb) {
      try {
        await _chatMessageDao.insertMessage(userMessage);
      } catch (e) {
        debugPrint('Error inserting user message: $e');
      }
    }

    _messages = [..._messages, userMessage];
    notifyListeners();

    // Simulate AI response after a delay
    await Future.delayed(const Duration(milliseconds: 1500));

    final responseText = _generateResponse();
    final aiMessage = ChatMessage(
      userId: _userId!,
      moongId: _moongId!,
      message: responseText,
      isUser: false,
    );

    if (!kIsWeb) {
      try {
        await _chatMessageDao.insertMessage(aiMessage);
      } catch (e) {
        debugPrint('Error inserting AI message: $e');
      }
    }

    _messages = [..._messages, aiMessage];
    notifyListeners();
  }

  Future<void> loadMoreMessages({int limit = 20}) async {
    if (kIsWeb || _moongId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final olderMessages = await _chatMessageDao.getMessagesByMoong(
        _moongId!,
        limit: limit,
        offset: _messages.length,
      );
      // olderMessages come in DESC order from DAO, reverse for chronological
      final chronological = olderMessages.reversed.toList();
      _messages = [...chronological, ..._messages];
    } catch (e) {
      debugPrint('Error loading more messages: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getConversationStats() async {
    if (kIsWeb || _moongId == null) {
      return {
        'total_messages': 0,
        'user_messages': 0,
        'moong_messages': 0,
        'first_message_time': null,
        'last_message_time': null,
      };
    }

    try {
      return await _chatMessageDao.getConversationStats(_moongId!);
    } catch (e) {
      debugPrint('Error getting conversation stats: $e');
      return {
        'total_messages': 0,
        'user_messages': 0,
        'moong_messages': 0,
        'first_message_time': null,
        'last_message_time': null,
      };
    }
  }

  String _generateResponse() {
    final random = Random();
    return _responses[random.nextInt(_responses.length)];
  }
}
