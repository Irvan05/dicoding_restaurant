import 'package:dicoding_restaurant/models/restaurant.dart';
import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';

class DatabaseProvider {
  static late Database _database;
  static const String _tableName = 'favorite_restaurant';

  Future<Database> get database async {
    _database = await _initializeDb();
    return _database;
  }

  Future<Database> _initializeDb() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'demo.db');

    var db = openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute(
          '''CREATE TABLE $_tableName (
             id TEXT PRIMARY KEY,
             name TEXT, description TEXT,
              pictureId TEXT, city TEXT,
              rating REAL, isFavorite INTEGER
           )''',
        );
      },
      version: 1,
    );
    return db;
  }

  Future<List<Restaurant>> getFavorite() async {
    final Database db = await database;
    List<Map<String, dynamic>> results = await db.query(_tableName);

    return results.map((res) => Restaurant.fromDBList(res)).toList();
  }

  Future<void> setFavorite(Restaurant restaurant) async {
    if (restaurant.isFavorite) {
      insertFavorite(restaurant);
    } else {
      deleteFavorite(restaurant.id);
    }
  }

  Future<void> insertFavorite(Restaurant restaurant) async {
    final Database db = await database;
    await db.insert(_tableName, restaurant.toJsonDb());
  }

  Future<void> deleteFavorite(String id) async {
    final db = await database;

    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
