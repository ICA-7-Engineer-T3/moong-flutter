import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._init();

  DatabaseHelper._init();

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError(
        'SQLite is not supported on web platform. '
        'Data persistence on web requires alternative storage solution.'
      );
    }
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'moong_app.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onConfigure(Database db) async {
    // Enable foreign key constraints
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

    // Create users table
    batch.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        nickname TEXT NOT NULL,
        level INTEGER NOT NULL DEFAULT 1,
        credits INTEGER NOT NULL DEFAULT 250,
        sprouts INTEGER NOT NULL DEFAULT 250,
        created_at INTEGER NOT NULL
      )
    ''');

    // Create moongs table
    batch.execute('''
      CREATE TABLE moongs (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        level INTEGER NOT NULL DEFAULT 1,
        intimacy INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        graduated_at INTEGER,
        is_active INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better query performance
    batch.execute('CREATE INDEX idx_moongs_user_id ON moongs(user_id)');
    batch.execute('CREATE INDEX idx_moongs_is_active ON moongs(is_active)');

    // Create quests table
    batch.execute('''
      CREATE TABLE quests (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        moong_id TEXT,
        type TEXT NOT NULL,
        target INTEGER NOT NULL,
        progress INTEGER NOT NULL DEFAULT 0,
        completed INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        completed_at INTEGER,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    batch.execute('CREATE INDEX idx_quests_user_id ON quests(user_id)');
    batch.execute('CREATE INDEX idx_quests_completed ON quests(completed)');

    // Create shop_items table
    batch.execute('''
      CREATE TABLE shop_items (
        id TEXT PRIMARY KEY,
        category TEXT NOT NULL,
        name TEXT NOT NULL,
        price INTEGER NOT NULL,
        currency TEXT NOT NULL,
        image_url TEXT,
        unlock_days INTEGER
      )
    ''');

    batch.execute('CREATE INDEX idx_shop_items_category ON shop_items(category)');

    // Create user_inventory table (for purchased items)
    batch.execute('''
      CREATE TABLE user_inventory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        shop_item_id TEXT NOT NULL,
        purchased_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (shop_item_id) REFERENCES shop_items(id) ON DELETE CASCADE,
        UNIQUE(user_id, shop_item_id)
      )
    ''');

    batch.execute('CREATE INDEX idx_user_inventory_user_id ON user_inventory(user_id)');

    // Create chat_messages table
    batch.execute('''
      CREATE TABLE chat_messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        moong_id TEXT NOT NULL,
        message TEXT NOT NULL,
        is_user INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (moong_id) REFERENCES moongs(id) ON DELETE CASCADE
      )
    ''');

    batch.execute('CREATE INDEX idx_chat_messages_user_id ON chat_messages(user_id)');
    batch.execute('CREATE INDEX idx_chat_messages_moong_id ON chat_messages(moong_id)');

    await batch.commit(noResult: true);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE quests ADD COLUMN moong_id TEXT');
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  // For testing purposes - delete database
  Future<void> deleteDb() async {
    String path = join(await getDatabasesPath(), 'moong_app.db');
    await deleteDatabase(path);
    _database = null;
  }
}
