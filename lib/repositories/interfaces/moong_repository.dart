import 'package:moong_flutter/models/moong.dart';

/// Repository interface for Moong data operations
abstract class MoongRepository {
  /// Get moong by user ID and moong ID
  Future<Moong?> getMoong(String userId, String moongId);

  /// Get all moongs for a user
  Future<List<Moong>> getMoongsByUser(String userId);

  /// Get active moongs for a user
  Future<List<Moong>> getActiveMoongs(String userId);

  /// Get the currently active moong for a user
  Future<Moong?> getActiveMoong(String userId);

  /// Get graduated moongs for a user
  Future<List<Moong>> getGraduatedMoongs(String userId);

  /// Create a new moong for a user
  Future<void> createMoong(String userId, Moong moong);

  /// Update an existing moong
  Future<void> updateMoong(String userId, Moong moong);

  /// Delete a moong
  Future<void> deleteMoong(String userId, String moongId);

  /// Create multiple moongs at once (batch operation)
  Future<void> createMoongs(String userId, List<Moong> moongs);
}
