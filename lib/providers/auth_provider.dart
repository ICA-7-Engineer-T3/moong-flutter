import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../database/user_dao.dart';

class AuthProvider with ChangeNotifier {
  final UserDao _userDao = UserDao();
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    if (kIsWeb) {
      debugPrint('Web platform - skipping database operations');
      _isLoading = false;
      return;
    }
    
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _userDao.getCurrentUser();
    } catch (e) {
      debugPrint('Error loading user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String nickname, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 실제 앱에서는 API 호출
      // 여기서는 간단한 로컬 인증
      await Future.delayed(const Duration(seconds: 1)); // API 호출 시뮬레이션

      _currentUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nickname: nickname,
      );

      if (!kIsWeb) {
        await _userDao.insertUser(_currentUser!);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error during login: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateCredits(int credits) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(credits: credits);
      if (!kIsWeb) {
        await _userDao.updateUser(_currentUser!);
      }
      notifyListeners();
    }
  }

  Future<void> updateSprouts(int sprouts) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(sprouts: sprouts);
      if (!kIsWeb) {
        await _userDao.updateUser(_currentUser!);
      }
      notifyListeners();
    }
  }

  Future<void> updateLevel(int level) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(level: level);
      if (!kIsWeb) {
        await _userDao.updateUser(_currentUser!);
      }
      notifyListeners();
    }
  }
}
