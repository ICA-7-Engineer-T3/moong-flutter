import 'package:flutter/material.dart';
import '../models/moong.dart';
import '../repositories/interfaces/moong_repository.dart';

class MoongProvider with ChangeNotifier {
  final MoongRepository _moongRepository;
  List<Moong> _moongs = [];
  Moong? _activeMoong;
  bool _isLoading = false;

  List<Moong> get moongs => _moongs;
  Moong? get activeMoong => _activeMoong;
  bool get isLoading => _isLoading;
  bool get hasMoong => _moongs.isNotEmpty;
  bool get hasActiveMoong => _activeMoong != null;

  MoongProvider({required MoongRepository moongRepository})
      : _moongRepository = moongRepository;

  /// Initialize with user ID
  Future<void> initialize(String userId) async {
    await _loadMoongs(userId);
  }

  Future<void> _loadMoongs(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _moongs = await _moongRepository.getMoongsByUser(userId);
      _activeMoong = await _moongRepository.getActiveMoong(userId);
    } catch (e) {
      debugPrint('Error loading moongs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createMoong(String userId, String name, MoongType type) async {
    try {
      final newMoong = Moong(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        name: name,
        type: type,
        createdAt: DateTime.now(),
      );

      await _moongRepository.createMoong(userId, newMoong);

      _moongs = [newMoong, ..._moongs];
      _activeMoong ??= newMoong;

      notifyListeners();
    } catch (e) {
      debugPrint('Error creating moong: $e');
      rethrow;
    }
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

  Future<void> updateMoongLevel(String userId, String moongId, int level) async {
    final index = _moongs.indexWhere((m) => m.id == moongId);
    if (index != -1) {
      try {
        final updatedMoong = _moongs[index].copyWith(level: level);

        await _moongRepository.updateMoong(userId, updatedMoong);

        _moongs = [
          ..._moongs.sublist(0, index),
          updatedMoong,
          ..._moongs.sublist(index + 1),
        ];

        if (_activeMoong?.id == moongId) {
          _activeMoong = updatedMoong;
        }

        notifyListeners();
      } catch (e) {
        debugPrint('Error updating moong level: $e');
        rethrow;
      }
    }
  }

  Future<void> updateMoongIntimacy(String userId, String moongId, int intimacy) async {
    final index = _moongs.indexWhere((m) => m.id == moongId);
    if (index != -1) {
      try {
        final updatedMoong = _moongs[index].copyWith(intimacy: intimacy);

        await _moongRepository.updateMoong(userId, updatedMoong);

        _moongs = [
          ..._moongs.sublist(0, index),
          updatedMoong,
          ..._moongs.sublist(index + 1),
        ];

        if (_activeMoong?.id == moongId) {
          _activeMoong = updatedMoong;
        }

        notifyListeners();
      } catch (e) {
        debugPrint('Error updating moong intimacy: $e');
        rethrow;
      }
    }
  }

  Future<void> graduateMoong(String userId, String moongId) async {
    final index = _moongs.indexWhere((m) => m.id == moongId);
    if (index != -1) {
      try {
        final updatedMoong = _moongs[index].copyWith(
          graduatedAt: DateTime.now(),
          isActive: false,
        );

        await _moongRepository.updateMoong(userId, updatedMoong);

        _moongs = [
          ..._moongs.sublist(0, index),
          updatedMoong,
          ..._moongs.sublist(index + 1),
        ];

        if (_activeMoong?.id == moongId) {
          // Find another active moong
          _activeMoong = _moongs.firstWhere(
            (m) => m.isActive && m.id != moongId,
            orElse: () => _moongs.first,
          );
        }

        notifyListeners();
      } catch (e) {
        debugPrint('Error graduating moong: $e');
        rethrow;
      }
    }
  }
}
