import 'dart:math';
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../repositories/interfaces/chat_message_repository.dart';

class ChatProvider with ChangeNotifier {
  final ChatMessageRepository _chatMessageRepository;
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

  ChatProvider({required ChatMessageRepository chatMessageRepository})
      : _chatMessageRepository = chatMessageRepository;

  Future<void> initialize(String userId, String moongId) async {
    _userId = userId;
    _moongId = moongId;

    _isLoading = true;
    notifyListeners();

    try {
      final recentMessages = await _chatMessageRepository.getRecentChatMessages(
        userId,
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

    try {
      final userMessage = ChatMessage(
        userId: _userId!,
        moongId: _moongId!,
        message: text,
        isUser: true,
      );

      await _chatMessageRepository.createChatMessage(_userId!, userMessage);

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

      await _chatMessageRepository.createChatMessage(_userId!, aiMessage);

      _messages = [..._messages, aiMessage];
      notifyListeners();
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }

  Future<void> loadMoreMessages({int limit = 20}) async {
    if (_userId == null || _moongId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final olderMessages = await _chatMessageRepository.getChatMessagesPage(
        _userId!,
        _moongId!,
        _messages.length,
        limit,
      );

      _messages = [...olderMessages, ..._messages];
    } catch (e) {
      debugPrint('Error loading more messages: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getConversationStats() async {
    if (_userId == null || _moongId == null) {
      return {
        'total': 0,
        'user': 0,
        'bot': 0,
      };
    }

    try {
      return await _chatMessageRepository.getConversationStats(_userId!, _moongId!);
    } catch (e) {
      debugPrint('Error getting conversation stats: $e');
      return {
        'total': 0,
        'user': 0,
        'bot': 0,
      };
    }
  }

  String _generateResponse() {
    final random = Random();
    return _responses[random.nextInt(_responses.length)];
  }
}
