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
      version: 1,
      onCreate: _onCreate,
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
        incomeBracket TEXT NOT NULL
      )
    ''');
    await _initializeAchievements(db);
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
    final List<Map<String, dynamic>> maps = await db.query('receipts');
    
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

  Future<int> getScanningStreak() async {
    final db = await database;
    final receipts = await db.query('receipts', orderBy: 'createdAt DESC');
    if (receipts.isEmpty) {
      return 0;
    }

    Set<DateTime> uniqueDates = {};
    for (var receipt in receipts) {
      final createdAt = DateTime.parse(receipt['createdAt'] as String);
      uniqueDates.add(DateTime(createdAt.year, createdAt.month, createdAt.day));
    }

    List<DateTime> sortedDates = uniqueDates.toList()..sort((a, b) => b.compareTo(a));

    DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    DateTime yesterday = today.subtract(const Duration(days: 1));

    if (sortedDates.first != today && sortedDates.first != yesterday) {
      return 0;
    }

    int streak = 1;
    for (int i = 0; i < sortedDates.length - 1; i++) {
      if (sortedDates[i].difference(sortedDates[i+1]).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  Future<int> getReceiptsScannedThisMonth() async {
    final db = await database;
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM receipts WHERE createdAt >= ? AND createdAt <= ?',
      [firstDayOfMonth.toIso8601String(), lastDayOfMonth.toIso8601String()],
    );
    return result.first['count'] as int? ?? 0;
  }
}