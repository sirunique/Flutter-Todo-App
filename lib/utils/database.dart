import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


import '../models/todo_item.dart';

class DatabaseHelper{
  static final DatabaseHelper _instance = new DatabaseHelper.internal();
  DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;
  final String tableName = 'todoTbl';
  final String columnId = 'id';
  final String columnItemName = 'itemName';
  final String columnDateCreated = 'dateCreated';

  static Database _db;

  Future<Database> get db async{
    if(_db != null){
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  initDb() async{
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'todo_db.db');

    var ourDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return ourDb;
  }

  // Create Database
  void _onCreate(Database db, int newVersion) async{
    await db.execute(
      "CREATE TABLE $tableName($columnId INTEGER PRIMARY KEY, $columnItemName TEXT, $columnDateCreated TEXT)"
    );
  }

  // Save 
  Future<int> saveItem(ToDoItem item) async{
    var dbClient = await db;
    var result = await dbClient.insert("$tableName", item.toMap());
    return result;
  }

  // Get All
  Future<List> getItems() async{
    var dbClient = await db;
    var result = await dbClient.rawQuery("SELECT * FROM $tableName ORDER BY $columnItemName ASC");
    return result.toList();
  }

  // Get By ID
  Future<ToDoItem> getItem(int id) async{
    var dbClient = await db;
    var result = await dbClient.rawQuery('SELECT * FROM $tableName WHERE $columnId = $id ');
    if(result.length == 0) return null;
    return new ToDoItem.fromMap(result.first);
  }

  // DELETE 
  Future<int> deleteItem(int id) async{
    var dbClient = await db;
    return await dbClient.delete(
      tableName,
      where: "$columnId = ? ",
      whereArgs: [id]
    );
  }

  // Update
  Future<int> updateItem(ToDoItem item) async{
    var dbClient = await db;
    return await dbClient.update(
      tableName,
      item.toMap(),
      where: "$columnId = ? ",
      whereArgs: [item.id]
    );
  }

  // Close Db
  Future close() async{
    var dbClient = await db;
    return dbClient.close();
  }

}