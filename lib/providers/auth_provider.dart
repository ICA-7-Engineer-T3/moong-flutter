import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../models/user.dart';
import '../repositories/interfaces/user_repository.dart';

/// Authentication provider using Firebase Auth and Firestore
class AuthProvider with ChangeNotifier {
  final auth.FirebaseAuth _firebaseAuth;
  final UserRepository _userRepository;
  User? _currentUser;
  bool _isLoading = false;
  StreamSubscription<auth.User?>? _authStateSubscription;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider({
    required auth.FirebaseAuth firebaseAuth,
    required UserRepository userRepository,
  })  : _firebaseAuth = firebaseAuth,
        _userRepository = userRepository {
    _initializeAuthListener();
  }

  /// Initialize Firebase Auth state listener
  void _initializeAuthListener() {
    _authStateSubscription = _firebaseAuth.authStateChanges().listen(
      _handleAuthStateChanged,
      onError: (error) {
        debugPrint('Auth state error: $error');
      },
    );
  }

  /// Handle Firebase Auth state changes
  Future<void> _handleAuthStateChanged(auth.User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Fetch user data from Firestore
      _currentUser = await _userRepository.getUser(firebaseUser.uid);

      // If user doesn't exist in Firestore (edge case), create one
      if (_currentUser == null) {
        _currentUser = User(
          id: firebaseUser.uid,
          email: firebaseUser.email,
          nickname: firebaseUser.email?.split('@').first ?? 'User',
        );
        await _userRepository.createUser(_currentUser!);
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign up with email, password, and nickname
  Future<bool> signup(String email, String password, String nickname) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Create Firebase Auth account
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Failed to create user account');
      }

      // Create User document in Firestore
      final newUser = User(
        id: firebaseUser.uid,
        email: email,
        nickname: nickname,
      );

      await _userRepository.createUser(newUser);
      _currentUser = newUser;

      _isLoading = false;
      notifyListeners();
      return true;
    } on auth.FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth error: ${e.code} - ${e.message}');
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Signup error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Sign in with Firebase Auth
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Login failed - no user returned');
      }

      // Fetch user data from Firestore
      _currentUser = await _userRepository.getUser(firebaseUser.uid);

      if (_currentUser == null) {
        throw Exception('User data not found in Firestore');
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on auth.FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth error: ${e.code} - ${e.message}');
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Logout error: $e');
      rethrow;
    }
  }

  /// Update user credits
  Future<void> updateCredits(int credits) async {
    if (_currentUser != null) {
      try {
        _currentUser = _currentUser!.copyWith(credits: credits);
        await _userRepository.updateUser(_currentUser!);
        notifyListeners();
      } catch (e) {
        debugPrint('Error updating credits: $e');
        rethrow;
      }
    }
  }

  /// Update user sprouts
  Future<void> updateSprouts(int sprouts) async {
    if (_currentUser != null) {
      try {
        _currentUser = _currentUser!.copyWith(sprouts: sprouts);
        await _userRepository.updateUser(_currentUser!);
        notifyListeners();
      } catch (e) {
        debugPrint('Error updating sprouts: $e');
        rethrow;
      }
    }
  }

  /// Update user level
  Future<void> updateLevel(int level) async {
    if (_currentUser != null) {
      try {
        _currentUser = _currentUser!.copyWith(level: level);
        await _userRepository.updateUser(_currentUser!);
        notifyListeners();
      } catch (e) {
        debugPrint('Error updating level: $e');
        rethrow;
      }
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
