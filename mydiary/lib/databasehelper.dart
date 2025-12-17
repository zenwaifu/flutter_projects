
import 'package:mydiary/diarylist.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _databaseName = "diarylist_app.db";
  static final _databaseVersion = 1;
  static final tablename = 'tbl_diary_log_list';

  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!; 
  }

  // Initializes the database by creating the table if it does not exist.
  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute(
          '''
          CREATE TABLE $tablename (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            notes TEXT,
            date TEXT,
            image TEXT
          )
          '''
        );
      },
    );
  }

  //create
  Future<int> insertDiaryList(DiaryList diarylist) async {
    final db = await database;

    final data = diarylist.toMap();
    data.remove("id"); // ⬅️ Force auto-increment

    return await db.insert(tablename, data);
  }

  //read all 
  Future<List<DiaryList>> getDiaryListsPaginated(int limit, int offset) async {
    final db = await database;
    // offset = offset - 1;
    final List<Map<String, dynamic>> result = await db.query(
      tablename,
      orderBy: 'id DESC',
      limit: limit,
      offset: offset,
      
    );

    return result.map((e) => DiaryList.fromMap(e)).toList();
  }

  // get page
  Future<List<DiaryList>> getPage(int pageNumber, int pageSize) async {
    int offset = pageNumber * pageSize;

    return await getDiaryListsPaginated(pageSize, offset);
  }

  // count totak num of row
  Future<int> getTotalCount() async {
    final db = await database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) as total FROM $tablename',
    );

    // result looks like: [{total: 25}]
    return Sqflite.firstIntValue(result) ?? 0;
  }

  //read - by id
  Future<DiaryList?> getDiaryListById(int id) async {
    final db = await database;
    final result = await db.query(tablename, where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return DiaryList.fromMap(result.first);
    }
    return null;
  }

  //update
  Future<int> updateDiaryList(DiaryList mylist) async {
    final db = await database;
    return await db.update(
      tablename,
      mylist.toMap(),
      where: 'id = ?',
      whereArgs: [mylist.id],
    );
  }

  //delete
  Future<int> deleteDiaryList(int id) async {
    final db = await database;
    return await db.delete(tablename, where: 'id = ?', whereArgs: [id]);
  }

  //delete all
  Future<int> deleteAll() async {
    final db = await database;
    return await db.delete(tablename);
  }

  //search - title or notes
  Future<List<DiaryList>> searchDiaryList(String text, int limit, int offset) async {
    final db = await database;
    final result = await db.query(
      tablename,
      where: 'title LIKE ? OR notes LIKE ?',
      whereArgs: ['%$text%', '%$text%'],
      orderBy: 'id DESC',
    );
    return result.map((e) => DiaryList.fromMap(e)).toList();
  }

  //get search count
  Future<int> getSearchCount(String text) async {
  final db = await database;

  final result = await db.rawQuery(
    '''
    SELECT COUNT(*) as total
    FROM $tablename
    WHERE title LIKE ? OR notes LIKE ?
    ''',
    ['%$text%', '%$text%'],
  );

  return Sqflite.firstIntValue(result) ?? 0;
}

  //close db
  Future<void> closeDb() async {
    final db = await database;
    await db.close();
  }
}