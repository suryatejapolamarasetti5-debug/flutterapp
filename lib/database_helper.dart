import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('streetlight.db');
    await _createDefaultAdmin(db: _database!);
    return _database!;
  }

  Future<void> initializeDatabase() async {
    await database;
    await _createDefaultAdmin(db: _database!);
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    final db = await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onupgradeDB,
    );

    await _ensureUserColumns(db);
    await _ensureComplaintColumns(db);
    await _createDefaultAdmin(db: db);

    return db;
  }
  // ============================================================
  // CREATE DATABASE
  // ============================================================

  Future<void> _createDB(
    Database db,
    int version,
  ) async {
    await db.execute('''
   CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'user'
)
    ''');

    await db.execute('''
      CREATE TABLE complaints (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        complaint_type TEXT NOT NULL,
        location TEXT NOT NULL,
        description TEXT NOT NULL,
        priority TEXT NOT NULL,
        status TEXT NOT NULL,
        image_path TEXT,
        created_at TEXT NOT NULL,
        latitude REAL,
        longitude REAL
      )
    ''');
    await _createDefaultAdmin(db: db);
  }

  // ============================================================
  // DATABASE UPGRADE
  // ============================================================

  Future<void> _onupgradeDB(
  Database db,
  int oldVersion,
  int newVersion,
) async {
  // Add role column if it doesn't exist
  final userColumns = await db.rawQuery(
    'PRAGMA table_info(users)',
  );

  final userColumnNames = userColumns
      .map((column) => column['name'] as String?)
      .whereType<String>()
      .toList();

  if (!userColumnNames.contains('role')) {
    await db.execute(
      "ALTER TABLE users ADD COLUMN role TEXT NOT NULL DEFAULT 'user'",
    );
  }

  // Add latitude if it doesn't exist
  await _ensureComplaintColumns(db);
}
  Future<void> _ensureUserColumns(Database db) async {
    final existingColumns = await db.rawQuery('PRAGMA table_info(users)');
    final columnNames = existingColumns
        .map((column) => column['name'] as String?)
        .whereType<String>()
        .toList();

    if (!columnNames.contains('role')) {
      await db.execute(
        "ALTER TABLE users ADD COLUMN role TEXT NOT NULL DEFAULT 'user'",
      );
    }
  }

  Future<void> _ensureComplaintColumns(Database db) async {
    final existingColumns = await db.rawQuery('PRAGMA table_info(complaints)');
    final columnNames = existingColumns
        .map((column) => column['name'] as String?)
        .whereType<String>()
        .toList();

    if (!columnNames.contains('latitude')) {
      await db.execute('ALTER TABLE complaints ADD COLUMN latitude REAL');
    }

    if (!columnNames.contains('longitude')) {
      await db.execute('ALTER TABLE complaints ADD COLUMN longitude REAL');
    }
  }

  // ============================================================
  // USER
  // ============================================================

 Future<int> insertUser(
  String name,
  String email,
  String password,
) async {
  final db = await database;

  return await db.insert(
    'users',
    {
      'name': name,
      'email': email,
      'password': password,
      'role': 'user',
    },
  );
  }

  Future<Map<String, dynamic>?> getUser(
    String email,
    String password,
  ) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  Future<Map<String, dynamic>?> getUserByEmail(
    String email,
  ) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  // ============================================================
  // INSERT COMPLAINT
  // ============================================================

  Future<int> insertComplaint(
  int userId,
  String complaintType,
  String location,
  String description,
  String priority,
  String status,
  String? imagePath,
  String createdAt, {
  double? latitude,
  double? longitude,
}) async {
    final db = await database;

    return await db.insert(
      'complaints',
      {
        'user_id': userId,
        'complaint_type': complaintType,
        'location': location,
        'description': description,
        'priority': priority,
        'status': status,
        'image_path': imagePath,
        'created_at': createdAt,
        'latitude': latitude,
        'longitude': longitude,
      },
    );
  }

  // ============================================================
  // GET ALL COMPLAINTS
  // ============================================================

  Future<List<Map<String, dynamic>>> getComplaints() async {
    final db = await database;

    return await db.query(
      'complaints',
      orderBy: 'id DESC',
    );
  }

  // ============================================================
  // UPDATE STATUS
  // ============================================================

  Future<int> updateComplaintStatus(
    int complaintId,
    String status,
  ) async {
    final db = await database;

    return await db.update(
      'complaints',
      {'status': status},
      where: 'id = ?',
      whereArgs: [complaintId],
    );
  }
Future<void> _createDefaultAdmin({required Database db}) async {
  final existingAdmin = await db.query(
    'users',
    where: 'email = ?',
    whereArgs: ['admin@streetlight.com'],
  );

  if (existingAdmin.isEmpty) {
    await db.insert('users', {
      'name': 'Administrator',
      'email': 'admin@streetlight.com',
      'password': 'admin123',
      'role': 'admin',
    });
  }
}
}