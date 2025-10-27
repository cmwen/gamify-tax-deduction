import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/data_models.dart';
import '../models/achievement.dart';

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
      version: 2,
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
    await _initializeAchievements(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        "ALTER TABLE user_profile ADD COLUMN taxCountry TEXT NOT NULL DEFAULT 'TaxCountry.unitedStates'",
      );
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
}
