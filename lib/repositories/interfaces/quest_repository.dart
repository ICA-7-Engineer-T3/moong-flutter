import 'package:moong_flutter/models/quest.dart';

/// Repository interface for Quest data operations
abstract class QuestRepository {
  /// Get quest by user ID and quest ID
  Future<Quest?> getQuest(String userId, String questId);

  /// Get all quests for a user
  Future<List<Quest>> getQuestsByUser(String userId);

  /// Get active (incomplete) quests for a user
  Future<List<Quest>> getActiveQuests(String userId);

  /// Get completed quests for a user
  Future<List<Quest>> getCompletedQuests(String userId);

  /// Get quests by moong ID
  Future<List<Quest>> getQuestsByMoong(String userId, String moongId);

  /// Create a new quest
  Future<void> createQuest(String userId, Quest quest);

  /// Update an existing quest
  Future<void> updateQuest(String userId, Quest quest);

  /// Delete a quest
  Future<void> deleteQuest(String userId, String questId);

  /// Update quest progress
  Future<void> updateQuestProgress(String userId, String questId, int progress);

  /// Mark quest as completed
  Future<void> completeQuest(String userId, String questId);

  /// Get quest completion count for a user
  Future<int> getQuestCompletionCount(String userId);

  /// Delete all quests for a specific moong
  Future<void> deleteQuestsByMoong(String userId, String moongId);

  /// Create multiple quests at once (batch operation)
  Future<void> createQuests(String userId, List<Quest> quests);
}
