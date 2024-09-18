import 'dart:io'; // Only one import is needed
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  // Singleton pattern to ensure only one instance of DatabaseHelper exists
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;

  final String tableName = "todoTbl";
  final String columnId = "id";
  final String columnItemName = "itemName";
  final String columnDateCreated = "dateCreated";

  static Database? _db;

  // Constructor
  DatabaseHelper.internal();

  // Get or initialize the database
  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDb();
    return _db!;
  }

  // Initialize the database
  Future<Database> initDb() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, "todo_db.db");
    var ourDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return ourDb;
  }

  // Create the database table
  void _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $tableName ("
            "$columnId INTEGER PRIMARY KEY AUTOINCREMENT, "
            "$columnItemName TEXT, "
            "$columnDateCreated TEXT)"
    );
    print('Table is created');
  }

  // Save a new item to the database
  Future<int> saveItem(Map<String, dynamic> item) async {
    var dbClient = await db;
    return await dbClient.insert(tableName, item);
  }

  // Update an existing item in the database
  Future<int> updateItem(Map<String, dynamic> item) async {
    var dbClient = await db;
    return await dbClient.update(
      tableName,
      item,
      where: '$columnId = ?',
      whereArgs: [item[columnId]],
    );
  }

  // Get a specific item by ID
  Future<Map<String, dynamic>?> getItem(int id) async {
    var dbClient = await db;
    List<Map<String, dynamic>> results = await dbClient.query(
      tableName,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Get all items from the database
  Future<List<Map<String, dynamic>>> getAllItems() async {
    var dbClient = await db;
    return await dbClient.query(tableName);
  }

  // Get the total count of items in the database
  Future<int> getCount() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(
        await dbClient.rawQuery('SELECT COUNT(*) FROM $tableName')
    )!;
  }

  // Delete an item from the database by ID
  Future<int> deleteItem(int id) async {
    var dbClient = await db;
    return await dbClient.delete(
      tableName,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  // Close the database
  Future<void> close() async {
    var dbClient = await db;
    await dbClient.close();
  }
}
