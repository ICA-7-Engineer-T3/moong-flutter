import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moong_flutter/models/moong.dart';
import 'package:moong_flutter/repositories/interfaces/moong_repository.dart';

/// Firestore implementation of MoongRepository
class MoongRepositoryFirestore implements MoongRepository {
  final FirebaseFirestore _firestore;
  static const String _usersCollection = 'users';
  static const String _moongsSubcollection = 'moongs';

  MoongRepositoryFirestore({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _moongsCollection(String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_moongsSubcollection);
  }

  @override
  Future<Moong?> getMoong(String userId, String moongId) async {
    try {
      final doc = await _moongsCollection(userId).doc(moongId).get();
      if (!doc.exists) return null;
      return Moong.fromFirestore(doc, userId);
    } catch (e) {
      throw Exception('Failed to get moong: $e');
    }
  }

  @override
  Future<List<Moong>> getMoongsByUser(String userId) async {
    try {
      final snapshot = await _moongsCollection(userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => Moong.fromFirestore(doc, userId))
          .toList();
    } catch (e) {
      throw Exception('Failed to get moongs by user: $e');
    }
  }

  @override
  Future<List<Moong>> getActiveMoongs(String userId) async {
    try {
      final snapshot = await _moongsCollection(userId)
          .where('isActive', isEqualTo: true)
          .where('graduatedAt', isNull: true)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => Moong.fromFirestore(doc, userId))
          .toList();
    } catch (e) {
      throw Exception('Failed to get active moongs: $e');
    }
  }

  @override
  Future<Moong?> getActiveMoong(String userId) async {
    try {
      final snapshot = await _moongsCollection(userId)
          .where('isActive', isEqualTo: true)
          .where('graduatedAt', isNull: true)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return null;
      return Moong.fromFirestore(snapshot.docs.first, userId);
    } catch (e) {
      throw Exception('Failed to get active moong: $e');
    }
  }

  @override
  Future<List<Moong>> getGraduatedMoongs(String userId) async {
    try {
      final snapshot = await _moongsCollection(userId)
          .where('graduatedAt', isNull: false)
          .orderBy('graduatedAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => Moong.fromFirestore(doc, userId))
          .toList();
    } catch (e) {
      throw Exception('Failed to get graduated moongs: $e');
    }
  }

  @override
  Future<void> createMoong(String userId, Moong moong) async {
    try {
      await _moongsCollection(userId)
          .doc(moong.id)
          .set(moong.toFirestore());
    } catch (e) {
      throw Exception('Failed to create moong: $e');
    }
  }

  @override
  Future<void> updateMoong(String userId, Moong moong) async {
    try {
      await _moongsCollection(userId)
          .doc(moong.id)
          .update(moong.toFirestore());
    } catch (e) {
      throw Exception('Failed to update moong: $e');
    }
  }

  @override
  Future<void> deleteMoong(String userId, String moongId) async {
    try {
      await _moongsCollection(userId).doc(moongId).delete();
    } catch (e) {
      throw Exception('Failed to delete moong: $e');
    }
  }

  @override
  Future<void> createMoongs(String userId, List<Moong> moongs) async {
    try {
      final batch = _firestore.batch();
      for (final moong in moongs) {
        final docRef = _moongsCollection(userId).doc(moong.id);
        batch.set(docRef, moong.toFirestore());
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to create moongs batch: $e');
    }
  }
}
