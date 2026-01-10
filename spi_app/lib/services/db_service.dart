import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/inspection.dart';

/// Database service for SQLite operations
/// Handles database creation and CRUD operations for inspections
class DBService {
  static Database? _db;

  /// Get database instance (singleton pattern)
  /// Creates database if it doesn't exist
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  /// Initialize database
  /// This method runs ONLY when database file doesn't exist
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'property_inspection.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create inspections table
        // This onCreate callback runs ONLY when database is first created
        await db.execute('''
          CREATE TABLE tbl_inspections(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            property_name TEXT NOT NULL,
            description TEXT NOT NULL,
            rating TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            date_created TEXT NOT NULL,
            photos TEXT NOT NULL
          )
        ''');
        
        print('Database created successfully with tbl_inspections table');
      },
    );
  }

  /// Insert new inspection into database
  /// Returns the ID of the inserted row
  Future<int> insertInspection(Inspection inspection) async {
    try {
      final db = await database;
      final id = await db.insert(
        'tbl_inspections',
        inspection.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Inspection inserted with ID: $id');
      return id;
    } catch (e) {
      print('Error inserting inspection: $e');
      rethrow;
    }
  }

  /// Get all inspections from database
  /// Returns list sorted by newest first (DESC by id)
  Future<List<Inspection>> getAllInspections() async {
    try {
      final db = await database;
      final result = await db.query(
        'tbl_inspections',
        orderBy: 'id DESC', // Newest first
      );
      
      print('Loaded ${result.length} inspections from database');
      return result.map((e) => Inspection.fromMap(e)).toList();
    } catch (e) {
      print('Error getting inspections: $e');
      rethrow;
    }
  }

  /// Update existing inspection in database
  /// Returns number of rows affected (should be 1)
  Future<int> updateInspection(Inspection inspection) async {
    if (inspection.id == null) {
      throw Exception('Cannot update inspection without ID');
    }

    try {
      final db = await database;
      final count = await db.update(
        'tbl_inspections',
        inspection.toMap(),
        where: 'id = ?',
        whereArgs: [inspection.id],
      );
      print('Updated $count inspection(s) with ID: ${inspection.id}');
      return count;
    } catch (e) {
      print('Error updating inspection: $e');
      rethrow;
    }
  }

  /// Delete inspection from database
  /// Returns number of rows deleted (should be 1)
  Future<int> deleteInspection(int id) async {
    try {
      final db = await database;
      final count = await db.delete(
        'tbl_inspections',
        where: 'id = ?',
        whereArgs: [id],
      );
      print('Deleted $count inspection(s) with ID: $id');
      return count;
    } catch (e) {
      print('Error deleting inspection: $e');
      rethrow;
    }
  }

  /// Get single inspection by ID
  Future<Inspection?> getInspectionById(int id) async {
    try {
      final db = await database;
      final result = await db.query(
        'tbl_inspections',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      
      if (result.isEmpty) return null;
      return Inspection.fromMap(result.first);
    } catch (e) {
      print('Error getting inspection by ID: $e');
      rethrow;
    }
  }

  /// Get total count of inspections
  Future<int> getTotalCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM tbl_inspections');
      final count = Sqflite.firstIntValue(result) ?? 0;
      return count;
    } catch (e) {
      print('Error getting count: $e');
      return 0;
    }
  }

  /// Close database connection
  Future<void> closeDatabase() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
      print('Database closed');
    }
  }

  /// Delete entire database (for testing/reset)
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'property_inspection.db');
    await databaseFactory.deleteDatabase(path);
    _db = null;
    print('Database deleted');
  }
}