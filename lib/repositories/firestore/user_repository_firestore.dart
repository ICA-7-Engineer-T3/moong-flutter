import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moong_flutter/models/user.dart';
import 'package:moong_flutter/repositories/interfaces/user_repository.dart';

/// Firestore implementation of UserRepository
class UserRepositoryFirestore implements UserRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'users';

  UserRepositoryFirestore({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<User?> getUser(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (!doc.exists) return null;
      return User.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    throw UnimplementedError(
      'getCurrentUser requires Firebase Auth integration. '
      'Use getUser(uid) with Firebase Auth currentUser.uid instead.',
    );
  }

  @override
  Future<void> createUser(User user) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(user.id)
          .set(user.toFirestore());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  @override
  Future<void> updateUser(User user) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(user.id)
          .update(user.toFirestore());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  @override
  Future<bool> userExists(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      return doc.exists;
    } catch (e) {
      throw Exception('Failed to check if user exists: $e');
    }
  }
}
