import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;

import 'package:my_finance/models/transaction.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mmm.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        comment TEXT,
        type TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertTransaction(Transaction t) async {
    final db = await database;
    final map = t.toMap()..remove('id');
    return db.insert('transactions', map);
  }

  Future<List<Transaction>> getTransactions() async {
    final db = await database;
    final maps = await db.query('transactions', orderBy: 'date DESC');
    return maps.map(Transaction.fromMap).toList();
  }

  Future<int> updateTransaction(Transaction t) async {
    final db = await database;
    return db.update(
      'transactions',
      t.toMap(),
      where: 'id = ?',
      whereArgs: [t.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}
