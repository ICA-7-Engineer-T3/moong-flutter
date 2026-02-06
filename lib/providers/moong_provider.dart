import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../models/moong.dart';
import '../database/moong_dao.dart';

class MoongProvider with ChangeNotifier {
  final MoongDao _moongDao = MoongDao();
  List<Moong> _moongs = [];
  Moong? _activeMoong;
  bool _isLoading = false;

  List<Moong> get moongs => _moongs;
  Moong? get activeMoong => _activeMoong;
  bool get isLoading => _isLoading;
  bool get hasMoong => _moongs.isNotEmpty;
  bool get hasActiveMoong => _activeMoong != null;

  MoongProvider();

  // Initialize with user ID
  Future<void> initialize(String userId) async {
    await _loadMoongs(userId);
  }

  Future<void> _loadMoongs(String userId) async {
    if (kIsWeb) {
      debugPrint('Web platform - skipping database operations');
      _isLoading = false;
      return;
    }
    
    _isLoading = true;
    notifyListeners();

    try {
      _moongs = await _moongDao.getMoongsByUserId(userId);
      _activeMoong = await _moongDao.getActiveMoong(userId);
    } catch (e) {
      debugPrint('Error loading moongs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> createMoong(String userId, String name, MoongType type) async {
    final newMoong = Moong(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      name: name,
      type: type,
      createdAt: DateTime.now(),
    );

    if (!kIsWeb) {
      await _moongDao.insertMoong(newMoong);
    }
    _moongs = [newMoong, ..._moongs];
    _activeMoong ??= newMoong;

    notifyListeners();
  }

  Future<void> setActiveMoong(String moongId) async {
    final index = _moongs.indexWhere((m) => m.id == moongId);
    if (index == -1) {
      debugPrint('Moong with id $moongId not found');
      return;
    }
    _activeMoong = _moongs[index];
    notifyListeners();
  }

  Future<void> updateMoongLevel(String moongId, int level) async {
    final index = _moongs.indexWhere((m) => m.id == moongId);
    if (index != -1) {
      final updatedMoong = _moongs[index].copyWith(level: level);
      _moongs = [
        ..._moongs.sublist(0, index),
        updatedMoong,
        ..._moongs.sublist(index + 1),
      ];
      if (!kIsWeb) {
        await _moongDao.updateMoong(updatedMoong);
      }
      if (_activeMoong?.id == moongId) {
        _activeMoong = updatedMoong;
      }
      notifyListeners();
    }
  }

  Future<void> updateMoongIntimacy(String moongId, int intimacy) async {
    final index = _moongs.indexWhere((m) => m.id == moongId);
    if (index != -1) {
      final updatedMoong = _moongs[index].copyWith(intimacy: intimacy);
      _moongs = [
        ..._moongs.sublist(0, index),
        updatedMoong,
        ..._moongs.sublist(index + 1),
      ];
      if (!kIsWeb) {
        await _moongDao.updateMoong(updatedMoong);
      }
      if (_activeMoong?.id == moongId) {
        _activeMoong = updatedMoong;
      }
      notifyListeners();
    }
  }

  Future<void> graduateMoong(String moongId) async {
    final index = _moongs.indexWhere((m) => m.id == moongId);
    if (index != -1) {
      final updatedMoong = _moongs[index].copyWith(
        graduatedAt: DateTime.now(),
        isActive: false,
      );
      _moongs = [
        ..._moongs.sublist(0, index),
        updatedMoong,
        ..._moongs.sublist(index + 1),
      ];
      if (!kIsWeb) {
        await _moongDao.updateMoong(updatedMoong);
      }

      if (_activeMoong?.id == moongId) {
        // 다른 활성 뭉이 있으면 그것을 활성화
        _activeMoong = _moongs.firstWhere(
          (m) => m.isActive && m.id != moongId,
          orElse: () => _moongs.first,
        );
      }

      notifyListeners();
    }
  }
}
