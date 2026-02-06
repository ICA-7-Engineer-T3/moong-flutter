import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moong_flutter/models/quest.dart';
import 'package:moong_flutter/repositories/interfaces/quest_repository.dart';

/// Firestore implementation of QuestRepository
class QuestRepositoryFirestore implements QuestRepository {
  final FirebaseFirestore _firestore;
  static const String _usersCollection = 'users';
  static const String _questsSubcollection = 'quests';

  QuestRepositoryFirestore({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _questsCollection(String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_questsSubcollection);
  }

  @override
  Future<Quest?> getQuest(String userId, String questId) async {
    try {
      final doc = await _questsCollection(userId).doc(questId).get();
      if (!doc.exists) return null;
      return Quest.fromFirestore(doc, userId);
    } catch (e) {
      throw Exception('Failed to get quest: $e');
    }
  }

  @override
  Future<List<Quest>> getQuestsByUser(String userId) async {
    try {
      final snapshot = await _questsCollection(userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => Quest.fromFirestore(doc, userId))
          .toList();
    } catch (e) {
      throw Exception('Failed to get quests by user: $e');
    }
  }

  @override
  Future<List<Quest>> getActiveQuests(String userId) async {
    try {
      final snapshot = await _questsCollection(userId)
          .where('completed', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => Quest.fromFirestore(doc, userId))
          .toList();
    } catch (e) {
      throw Exception('Failed to get active quests: $e');
    }
  }

  @override
  Future<List<Quest>> getCompletedQuests(String userId) async {
    try {
      final snapshot = await _questsCollection(userId)
          .where('completed', isEqualTo: true)
          .orderBy('completedAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => Quest.fromFirestore(doc, userId))
          .toList();
    } catch (e) {
      throw Exception('Failed to get completed quests: $e');
    }
  }

  @override
  Future<List<Quest>> getQuestsByMoong(String userId, String moongId) async {
    try {
      final snapshot = await _questsCollection(userId)
          .where('moongId', isEqualTo: moongId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => Quest.fromFirestore(doc, userId))
          .toList();
    } catch (e) {
      throw Exception('Failed to get quests by moong: $e');
    }
  }

  @override
  Future<void> createQuest(String userId, Quest quest) async {
    try {
      await _questsCollection(userId).doc(quest.id).set(quest.toFirestore());
    } catch (e) {
      throw Exception('Failed to create quest: $e');
    }
  }

  @override
  Future<void> updateQuest(String userId, Quest quest) async {
    try {
      await _questsCollection(userId)
          .doc(quest.id)
          .update(quest.toFirestore());
    } catch (e) {
      throw Exception('Failed to update quest: $e');
    }
  }

  @override
  Future<void> deleteQuest(String userId, String questId) async {
    try {
      await _questsCollection(userId).doc(questId).delete();
    } catch (e) {
      throw Exception('Failed to delete quest: $e');
    }
  }

  @override
  Future<void> updateQuestProgress(String userId, String questId, int progress) async {
    try {
      await _questsCollection(userId).doc(questId).update({
        'progress': progress,
      });
    } catch (e) {
      throw Exception('Failed to update quest progress: $e');
    }
  }

  @override
  Future<void> completeQuest(String userId, String questId) async {
    try {
      await _questsCollection(userId).doc(questId).update({
        'completed': true,
        'completedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to complete quest: $e');
    }
  }

  @override
  Future<int> getQuestCompletionCount(String userId) async {
    try {
      final snapshot = await _questsCollection(userId)
          .where('completed', isEqualTo: true)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get quest completion count: $e');
    }
  }

  @override
  Future<void> deleteQuestsByMoong(String userId, String moongId) async {
    try {
      final snapshot = await _questsCollection(userId)
          .where('moongId', isEqualTo: moongId)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete quests by moong: $e');
    }
  }

  @override
  Future<void> createQuests(String userId, List<Quest> quests) async {
    try {
      final batch = _firestore.batch();
      for (final quest in quests) {
        final docRef = _questsCollection(userId).doc(quest.id);
        batch.set(docRef, quest.toFirestore());
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to create quests batch: $e');
    }
  }
}
