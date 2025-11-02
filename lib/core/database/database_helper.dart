import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/data_models.dart';
import '../models/achievement.dart';
import '../models/work_from_home_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  static DatabaseHelper get instance => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'tax_deduction.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE receipts(
        id TEXT PRIMARY KEY,
        createdAt TEXT NOT NULL,
        imagePath TEXT NOT NULL,
        vendorName TEXT,
        totalAmount REAL NOT NULL,
        potentialTaxSaving REAL NOT NULL,
        category TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE achievements(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        unlocked INTEGER NOT NULL,
        unlockedAt TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE user_profile(
        id TEXT PRIMARY KEY,
        filingStatus TEXT NOT NULL,
        incomeBracket TEXT NOT NULL,
        taxCountry TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE work_from_home_entries(
        id TEXT PRIMARY KEY,
        workingDate TEXT NOT NULL UNIQUE,
        hours REAL NOT NULL
      )
    ''');
    await _initializeAchievements(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        "ALTER TABLE user_profile ADD COLUMN taxCountry TEXT NOT NULL DEFAULT 'TaxCountry.unitedStates'",
      );
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS work_from_home_entries(
          id TEXT PRIMARY KEY,
          workingDate TEXT NOT NULL UNIQUE,
          hours REAL NOT NULL
        )
      ''');
    }
  }

  Future<void> _initializeAchievements(Database db) async {
    for (var achievement in Achievements.all) {
      await db.insert('achievements', achievement.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Future<int> insertReceipt(Receipt receipt) async {
    final db = await database;
    return await db.insert('receipts', receipt.toMap());
  }

  Future<void> updateReceipt(Receipt receipt) async {
    final db = await database;
    await db.update(
      'receipts',
      receipt.toMap(),
      where: 'id = ?',
      whereArgs: [receipt.id],
    );
  }

  Future<void> deleteReceipt(String id) async {
    final db = await database;
    await db.delete(
      'receipts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Receipt>> getAllReceipts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'receipts',
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return Receipt.fromMap(maps[i]);
    });
  }

  Future<Receipt?> getReceiptById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'receipts',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) {
      return null;
    }
    return Receipt.fromMap(maps.first);
  }

  Future<double> getTotalPotentialSavings() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(potentialTaxSaving) as total FROM receipts',
    );

    return result.first['total'] as double? ?? 0.0;
  }

  Future<int> getReceiptCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM receipts');
    return result.first['count'] as int? ?? 0;
  }

  Future<List<Achievement>> getAchievements() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('achievements');
    return List.generate(maps.length, (i) {
      return Achievement.fromMap(maps[i]);
    });
  }

  Future<void> updateAchievement(Achievement achievement) async {
    final db = await database;
    await db.update(
      'achievements',
      achievement.toMap(),
      where: 'id = ?',
      whereArgs: [achievement.id],
    );
  }

  Future<void> upsertWorkFromHomeEntries(
      List<WorkFromHomeEntry> entries) async {
    final db = await database;
    await db.transaction((txn) async {
      for (final entry in entries) {
        await txn.insert(
          'work_from_home_entries',
          entry.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<WorkFromHomeEntry>> getWorkFromHomeEntries() async {
    final db = await database;
    final maps = await db.query(
      'work_from_home_entries',
      orderBy: 'workingDate DESC',
    );
    return List.generate(
        maps.length, (index) => WorkFromHomeEntry.fromMap(maps[index]));
  }

  Future<void> deleteWorkFromHomeEntry(String id) async {
    final db = await database;
    await db.delete(
      'work_from_home_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteWorkFromHomeEntryByDate(DateTime date) async {
    final db = await database;
    await db.delete(
      'work_from_home_entries',
      where: 'workingDate = ?',
      whereArgs: [date.toIso8601String()],
    );
  }
}
