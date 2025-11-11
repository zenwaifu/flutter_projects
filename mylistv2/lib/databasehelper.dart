import 'package:mylistv2/mylist.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _databaseName = "mylistv2.db";
  static final _databaseVersion = 1;
  static final tablename = 'tbl_mylist';

  static final DatabaseHelper _instance = DatabaseHelper._internal();  
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;
  Future<Database> get database async {
      if (_db != null) return _db!;
      _db = await _initDb();
      return _db!;
  }

  //CREATE DATABASE
  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tablename (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            status TEXT,
            date TEXT,
            imagename TEXT
          )
        ''');
      },
    );
  }

//CREATE TABLE METHODS
  Future<int> insertMyList(MyList mylist) async {
    final db = await database;
    return await db.insert(
      tablename, 
      mylist.toMap());
  }

//READ TABLE (get all records)
  Future<List<MyList>> getAllMyList() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(tablename, orderBy: 'id DESC');
    return result.map((e) => MyList.fromMap(e)).toList();
  }

//READ TABLE (get single record)
  Future<MyList?> getListById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      tablename,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return MyList.fromMap(result.first);
    }
    return null;
  }

//UPDATE TABLE
  // Future<int> updateMyList(MyList mylist) async {
  //   final db = await database;
  //   return await db.update(
  //     tablename,
  //     mylist.toMap(),
  //     where: 'id = ?',
  //     whereArgs: [mylist.id],
  //   );
  // }

//DELETE FROM TABLE (by id)
  Future<int> deleteMyList(int id) async {
    final db = await database;
    return await db.delete(
      tablename,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //DELETE ALL RECORDS FROM TABLE
  Future<int> deleteAll() async {
    final db = await database;
    return await db.delete(tablename);
  }

  //SEARCH (by title or description)
  Future<List<MyList>> searchMyList(String keyword) async {
    final db = await database;
    final result = await db.query(
      tablename,
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
    );
    return result.map((e) => MyList.fromMap(e)).toList();
  }

  //Close database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}