import 'package:moong_flutter/database/moong_dao.dart';
import 'package:moong_flutter/models/moong.dart';
import 'package:moong_flutter/repositories/interfaces/moong_repository.dart';

/// SQLite implementation of MoongRepository
/// Wraps MoongDao to conform to repository interface
class MoongRepositorySQLite implements MoongRepository {
  final MoongDao _dao = MoongDao();

  @override
  Future<Moong?> getMoong(String userId, String moongId) =>
      _dao.getMoong(moongId);

  @override
  Future<List<Moong>> getMoongsByUser(String userId) =>
      _dao.getMoongsByUserId(userId);

  @override
  Future<List<Moong>> getActiveMoongs(String userId) =>
      _dao.getActiveMoongs(userId);

  @override
  Future<Moong?> getActiveMoong(String userId) =>
      _dao.getActiveMoong(userId);

  @override
  Future<List<Moong>> getGraduatedMoongs(String userId) =>
      _dao.getGraduatedMoongs(userId);

  @override
  Future<void> createMoong(String userId, Moong moong) async {
    await _dao.insertMoong(moong);
  }

  @override
  Future<void> updateMoong(String userId, Moong moong) async {
    await _dao.updateMoong(moong);
  }

  @override
  Future<void> deleteMoong(String userId, String moongId) async {
    await _dao.deleteMoong(moongId);
  }

  @override
  Future<void> createMoongs(String userId, List<Moong> moongs) async {
    for (var moong in moongs) {
      await _dao.insertMoong(moong);
    }
  }
}
