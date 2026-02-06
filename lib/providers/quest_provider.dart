import 'package:flutter/material.dart';
import '../models/quest.dart';
import '../repositories/interfaces/quest_repository.dart';

class QuestProvider with ChangeNotifier {
  final QuestRepository _questRepository;
  List<Quest> _quests = [];
  bool _isLoading = false;
  String? _userId;

  List<Quest> get quests => _quests;
  bool get isLoading => _isLoading;

  List<Quest> get activeQuests =>
      _quests.where((q) => !q.completed).toList();

  List<Quest> get completedQuests =>
      _quests.where((q) => q.completed).toList();

  QuestProvider({required QuestRepository questRepository})
      : _questRepository = questRepository;

  Future<void> initialize(String userId) async {
    _userId = userId;
    await loadQuests();
  }

  Future<void> loadQuests() async {
    if (_userId == null) {
      debugPrint('Cannot load quests: userId is null');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _quests = await _questRepository.getQuestsByUser(_userId!);
    } catch (e) {
      debugPrint('Error loading quests: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProgress(String questId, int progress) async {
    if (_userId == null) {
      debugPrint('Cannot update progress: userId is null');
      return;
    }

    try {
      await _questRepository.updateQuestProgress(_userId!, questId, progress);

      final index = _quests.indexWhere((q) => q.id == questId);
      if (index != -1) {
        _quests = [
          ..._quests.sublist(0, index),
          _quests[index].copyWith(progress: progress),
          ..._quests.sublist(index + 1),
        ];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating quest progress: $e');
      rethrow;
    }
  }

  Future<void> completeQuest(
    String questId, {
    Function(int sprouts)? onSproutsEarned,
    Function(String moongId, int intimacyIncrease)? onIntimacyEarned,
  }) async {
    if (_userId == null) {
      debugPrint('Cannot complete quest: userId is null');
      return;
    }

    try {
      await _questRepository.completeQuest(_userId!, questId);

      final now = DateTime.now();
      final index = _quests.indexWhere((q) => q.id == questId);
      if (index != -1) {
        final quest = _quests[index];
        _quests = [
          ..._quests.sublist(0, index),
          quest.copyWith(completed: true, completedAt: now),
          ..._quests.sublist(index + 1),
        ];
        notifyListeners();

        // Reward calculation based on quest target
        final sproutsReward = (quest.target / 1000).round() * 10; // 3000 steps = 30 sprouts, 7000 = 70, etc.
        final intimacyIncrease = (quest.target / 1000).round(); // 3000 steps = 3 intimacy, 7000 = 7, etc.

        // Notify callbacks for cross-provider coordination
        if (onSproutsEarned != null) {
          onSproutsEarned(sproutsReward);
        }
        if (onIntimacyEarned != null && quest.moongId != null) {
          onIntimacyEarned(quest.moongId!, intimacyIncrease);
        }
      }
    } catch (e) {
      debugPrint('Error completing quest: $e');
      rethrow;
    }
  }

  Future<void> createDailyQuests(String userId, String? moongId) async {
    final now = DateTime.now();
    final targets = [3000, 7000, 10000];

    final dailyQuests = targets.map((target) {
      return Quest(
        id: '${now.millisecondsSinceEpoch}_$target',
        userId: userId,
        moongId: moongId,
        type: QuestType.walk,
        target: target,
        progress: 0,
        completed: false,
        createdAt: now,
      );
    }).toList();

    try {
      await _questRepository.createQuests(userId, dailyQuests);
      _userId = userId;
      await loadQuests();
    } catch (e) {
      debugPrint('Error creating daily quests: $e');
      rethrow;
    }
  }
}
