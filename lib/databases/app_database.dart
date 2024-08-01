import 'package:offline_online_sync_app/models/user.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();

  AppDatabase._init();

  static const String tableUsers = "users";

  static const idType = "INTEGER PRIMARY KEY AUTOINCREMENT";
  static const textType = "TEXT";
  static const integerType = "INTEGER NOT NULL";
  static const boolType = "BOOL NOT NULL";
  static const floatType = "FLOAT NOT NULL";

  static Database? _database;
  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await _initDB("users.db");
    return _database;
  }

  Future<Database?> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _creatDB);
  }

  Future _creatDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableUsers (
        ${UserFields.id} $idType,
        ${UserFields.createdAt} $textType,
        ${UserFields.name} $textType,
        ${UserFields.avatar} $textType,
        ${UserFields.isSynced} $integerType
      )
  ''');
  }

  Future<User> createUser(User user) async {
    final db = await instance.database;

    final id = await db!.insert(tableUsers, user.toJsonLocal());
    print("Success");
    return user.copy(createdAt: user.createdAt, id: id.toString());
  }

  Future<User?> read(int id) async {
    final db = await instance.database;

    final maps = await db!.query(
      tableUsers,
      columns: UserFields.values,
      where: "${UserFields.id} = ?",
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromJsonLocal(maps.first);
    } else {
      return null;
    }
  }

  Future<List<User>> readAllUsers() async {
    final db = await instance.database;

    const orderBy = "${UserFields.id} ASC";
    final result = await db!.query(tableUsers, orderBy: orderBy);

    return result.map((json) => User.fromJsonLocal(json)).toList();
  }

  Future<List<User>> readAllUsersUnsynced() async {
    final db = await instance.database;

    final result = await db!.query(
      tableUsers,
      where: "${UserFields.isSynced} = ?",
      whereArgs: [0],
    );

    return result.map((json) => User.fromJson(json)).toList();
  }

  Future<int> updateUser(User user) async {
    final db = await instance.database;

    return db!.update(
      tableUsers,
      user.toJsonLocal(),
      where: "${UserFields.id} = ?",
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await instance.database;

    return db!.delete(
      tableUsers,
      where: "${UserFields.id} = ?",
      whereArgs: [id],
    );
  }

  Future closeDB() async {
    final db = await instance.database;

    db!.close();
  }
}
