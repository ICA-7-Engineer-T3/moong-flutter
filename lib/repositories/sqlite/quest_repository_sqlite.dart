import 'package:moong_flutter/database/quest_dao.dart';
import 'package:moong_flutter/models/quest.dart';
import 'package:moong_flutter/repositories/interfaces/quest_repository.dart';

/// SQLite implementation of QuestRepository
/// Wraps QuestDao to conform to repository interface
class QuestRepositorySQLite implements QuestRepository {
  final QuestDao _dao = QuestDao();

  @override
  Future<Quest?> getQuest(String userId, String questId) =>
      _dao.getQuest(questId);

  @override
  Future<List<Quest>> getQuestsByUser(String userId) =>
      _dao.getQuestsByUserId(userId);

  @override
  Future<List<Quest>> getActiveQuests(String userId) =>
      _dao.getActiveQuests(userId);

  @override
  Future<List<Quest>> getCompletedQuests(String userId) =>
      _dao.getCompletedQuests(userId);

  @override
  Future<List<Quest>> getQuestsByMoong(String userId, String moongId) async {
    // Note: QuestDao doesn't have getQuestsByMoongId - filter in memory for now
    final allQuests = await _dao.getQuestsByUserId(userId);
    return allQuests.where((q) => q.moongId == moongId).toList();
  }

  @override
  Future<void> createQuest(String userId, Quest quest) async {
    await _dao.insertQuest(quest);
  }

  @override
  Future<void> updateQuest(String userId, Quest quest) async {
    await _dao.updateQuest(quest);
  }

  @override
  Future<void> deleteQuest(String userId, String questId) async {
    await _dao.deleteQuest(questId);
  }

  @override
  Future<void> updateQuestProgress(String userId, String questId, int progress) async {
    await _dao.updateQuestProgress(questId, progress);
  }

  @override
  Future<void> completeQuest(String userId, String questId) async {
    await _dao.completeQuest(questId);
  }

  @override
  Future<int> getQuestCompletionCount(String userId) async {
    final completed = await _dao.getCompletedQuests(userId);
    return completed.length;
  }

  @override
  Future<void> deleteQuestsByMoong(String userId, String moongId) async {
    // Note: QuestDao doesn't have deleteQuestsByMoongId - delete individually
    final quests = await _dao.getQuestsByUserId(userId);
    for (var quest in quests.where((q) => q.moongId == moongId)) {
      await _dao.deleteQuest(quest.id);
    }
  }

  @override
  Future<void> createQuests(String userId, List<Quest> quests) async {
    for (var quest in quests) {
      await _dao.insertQuest(quest);
    }
  }
}
