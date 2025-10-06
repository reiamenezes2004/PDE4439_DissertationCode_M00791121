import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _db;

  DatabaseHelper._internal();

  Future<Database> get db async {
    return _db ??= await _initDb();
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ocp_users.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        password TEXT,
        numberPlate TEXT,
        isEv INTEGER
      )
    ''');
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    final database = await db;
    return await database.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUser(String name, String password) async {
    final database = await db;
    final res = await database.query(
      'users',
      where: 'name = ? AND password = ?',
      whereArgs: [name, password],
    );
    return res.isNotEmpty ? res.first : null;
  }
}
