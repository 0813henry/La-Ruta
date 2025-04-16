import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:restaurante_app/core/model/pedido_model.dart';
import 'dart:convert';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._init();

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('restaurante.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        cliente TEXT,
        items TEXT,
        total REAL,
        estado TEXT
      )
    ''');
  }

  Future<int> insertOrder(OrderModel order) async {
    final db = await instance.database;
    final orderMap = order.toMap();
    orderMap['items'] = jsonEncode(order.items.map((item) => item.toMap()).toList());
    return await db.insert('orders', orderMap);
  }

  Future<List<OrderModel>> getOrders() async {
    final db = await instance.database;
    final result = await db.query('orders');

    return result.map((map) => OrderModel.fromMap(map)).toList();
  }
}
