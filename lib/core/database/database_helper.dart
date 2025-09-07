import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/data_models.dart';

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
}