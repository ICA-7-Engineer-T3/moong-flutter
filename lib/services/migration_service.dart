import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import '../models/moong.dart';
import '../database/user_dao.dart';
import '../database/moong_dao.dart';

class MigrationService {
  static const String _migrationCompletedKey = 'migration_completed';
  
  final UserDao _userDao = UserDao();
  final MoongDao _moongDao = MoongDao();

  /// Check if migration has already been completed
  Future<bool> isMigrationCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_migrationCompletedKey) ?? false;
    } catch (e) {
      debugPrint('Error checking migration status: $e');
      return false;
    }
  }

  /// Mark migration as completed
  Future<void> _markMigrationCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_migrationCompletedKey, true);
    } catch (e) {
      debugPrint('Error marking migration as completed: $e');
    }
  }

  /// Migrate data from SharedPreferences to SQLite
  Future<void> migrateFromSharedPreferences() async {
    try {
      // Check if migration already completed
      if (await isMigrationCompleted()) {
        print('Migration already completed, skipping...');
        return;
      }

      print('Starting migration from SharedPreferences to SQLite...');

      final prefs = await SharedPreferences.getInstance();

      // Migrate user data
      await _migrateUser(prefs);

      // Migrate moong data
      await _migrateMoongs(prefs);

      // Mark migration as completed
      await _markMigrationCompleted();

      print('Migration completed successfully!');
    } catch (e) {
      debugPrint('Error during migration: $e');
      rethrow;
    }
  }

  /// Migrate user data
  Future<void> _migrateUser(SharedPreferences prefs) async {
    try {
      final userJson = prefs.getString('current_user');
      
      if (userJson != null) {
        print('Migrating user data...');
        
        final userMap = jsonDecode(userJson);
        final user = User.fromJson(userMap);
        
        // Check if user already exists in database
        final existingUser = await _userDao.getUser(user.id);
        if (existingUser == null) {
          await _userDao.insertUser(user);
          print('User migrated successfully: ${user.nickname}');
        } else {
          print('User already exists in database, skipping...');
        }

        // Remove from SharedPreferences after successful migration
        await prefs.remove('current_user');
      } else {
        print('No user data to migrate');
      }
    } catch (e) {
      debugPrint('Error migrating user: $e');
      // Don't rethrow - continue with other migrations
    }
  }

  /// Migrate moong data
  Future<void> _migrateMoongs(SharedPreferences prefs) async {
    try {
      final moongsJson = prefs.getString('moongs');
      
      if (moongsJson != null) {
        print('Migrating moong data...');
        
        final List<dynamic> moongsList = jsonDecode(moongsJson);
        final moongs = moongsList.map((json) => Moong.fromJson(json)).toList();
        
        int migratedCount = 0;
        for (var moong in moongs) {
          // Check if moong already exists in database
          final existingMoong = await _moongDao.getMoong(moong.id);
          if (existingMoong == null) {
            await _moongDao.insertMoong(moong);
            migratedCount++;
          }
        }
        
        print('Migrated $migratedCount moong(s) successfully');

        // Remove from SharedPreferences after successful migration
        await prefs.remove('moongs');
        await prefs.remove('active_moong_id');
      } else {
        print('No moong data to migrate');
      }
    } catch (e) {
      debugPrint('Error migrating moongs: $e');
      // Don't rethrow - continue
    }
  }

  /// Force reset migration (for testing purposes)
  Future<void> resetMigration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_migrationCompletedKey);
      print('Migration flag reset');
    } catch (e) {
      debugPrint('Error resetting migration: $e');
    }
  }
}
