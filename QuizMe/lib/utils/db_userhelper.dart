import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

//going to store the file on the same folder
//pass the user(name) who logs in to other files
class DBHelper {
  DBHelper._privateConstructor();

  static DBHelper dbHelper = DBHelper._privateConstructor();

  late Database _database;

  Future<Database> get database async {
    _database = await _createDatabase();
    return _database;
  }

  Future<Database> _createDatabase() async {
    Database database =
        await openDatabase(join(await getDatabasesPath(), 'Users.db'),
            onCreate: (Database db, int version) {
      db.execute(
          "CREATE TABLE Students( id INTEGER PRIMARY KEY, email TEXT, password TEXT, username TEXT)");
    }, version: 1);
    return database;
  }

  //Todo
  Future<List<Map<String, dynamic>>> getData() async {
    Database db = await database;
    return await db.query("Users");
  }

  Future<int> insertUser(Map<String, dynamic> row) async {
    Database db = await database;
    return db.insert("Users", row);
  }

  Future<int> deleteGrade(String sid) async {
    Database db = await database;
    return await db.delete("Users", where: "email=?", whereArgs: [sid]);
  }
}
