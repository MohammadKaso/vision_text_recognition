import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/order.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('orders.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        source TEXT NOT NULL,
        status TEXT NOT NULL,
        customer_name TEXT,
        customer_contact TEXT,
        items TEXT NOT NULL,
        original_text TEXT,
        image_path TEXT,
        audio_path TEXT,
        notes TEXT,
        metadata TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE order_corrections (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id TEXT NOT NULL,
        field_name TEXT NOT NULL,
        original_value TEXT NOT NULL,
        corrected_value TEXT NOT NULL,
        confidence_before REAL,
        confidence_after REAL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders (id)
      )
    ''');
  }

  Future<void> initialize() async {
    await database;
  }

  Future<String> createOrder(Order order) async {
    final db = await instance.database;

    await db.insert('orders', _orderToMap(order));
    return order.id;
  }

  Future<Order?> getOrder(String id) async {
    final db = await instance.database;

    final maps = await db.query('orders', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return _orderFromMap(maps.first);
    }
    return null;
  }

  Future<List<Order>> getAllOrders({
    OrderStatus? status,
    OrderSource? source,
    int? limit,
    int? offset,
  }) async {
    final db = await instance.database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (status != null) {
      whereClause += 'status = ?';
      whereArgs.add(status.name);
    }

    if (source != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'source = ?';
      whereArgs.add(source.name);
    }

    final maps = await db.query(
      'orders',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );

    return maps.map((map) => _orderFromMap(map)).toList();
  }

  Future<void> updateOrder(Order order) async {
    final db = await instance.database;

    await db.update(
      'orders',
      _orderToMap(order),
      where: 'id = ?',
      whereArgs: [order.id],
    );
  }

  Future<void> deleteOrder(String id) async {
    final db = await instance.database;

    await db.delete('orders', where: 'id = ?', whereArgs: [id]);

    // Also delete related corrections
    await db.delete(
      'order_corrections',
      where: 'order_id = ?',
      whereArgs: [id],
    );
  }

  Future<void> saveCorrection({
    required String orderId,
    required String fieldName,
    required String originalValue,
    required String correctedValue,
    double? confidenceBefore,
    double? confidenceAfter,
  }) async {
    final db = await instance.database;

    await db.insert('order_corrections', {
      'order_id': orderId,
      'field_name': fieldName,
      'original_value': originalValue,
      'corrected_value': correctedValue,
      'confidence_before': confidenceBefore,
      'confidence_after': confidenceAfter,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getCorrections(String orderId) async {
    final db = await instance.database;

    return await db.query(
      'order_corrections',
      where: 'order_id = ?',
      whereArgs: [orderId],
      orderBy: 'created_at DESC',
    );
  }

  // Analytics methods
  Future<Map<String, int>> getOrderCountByStatus() async {
    final db = await instance.database;

    final maps = await db.rawQuery('''
      SELECT status, COUNT(*) as count 
      FROM orders 
      GROUP BY status
    ''');

    Map<String, int> result = {};
    for (final map in maps) {
      result[map['status'] as String] = map['count'] as int;
    }
    return result;
  }

  Future<Map<String, int>> getOrderCountBySource() async {
    final db = await instance.database;

    final maps = await db.rawQuery('''
      SELECT source, COUNT(*) as count 
      FROM orders 
      GROUP BY source
    ''');

    Map<String, int> result = {};
    for (final map in maps) {
      result[map['source'] as String] = map['count'] as int;
    }
    return result;
  }

  Future<List<Map<String, dynamic>>> getRecentOrders(int limit) async {
    final db = await instance.database;

    return await db.query('orders', orderBy: 'created_at DESC', limit: limit);
  }

  Map<String, dynamic> _orderToMap(Order order) {
    return {
      'id': order.id,
      'created_at': order.createdAt.toIso8601String(),
      'updated_at': order.updatedAt?.toIso8601String(),
      'source': order.source.name,
      'status': order.status.name,
      'customer_name': order.customerName,
      'customer_contact': order.customerContact,
      'items': jsonEncode(order.items.map((item) => item.toJson()).toList()),
      'original_text': order.originalText,
      'image_path': order.imagePath,
      'audio_path': order.audioPath,
      'notes': order.notes,
      'metadata': order.metadata != null ? jsonEncode(order.metadata) : null,
    };
  }

  Order _orderFromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
      source: OrderSource.values.byName(map['source']),
      status: OrderStatus.values.byName(map['status']),
      customerName: map['customer_name'],
      customerContact: map['customer_contact'],
      items: (jsonDecode(map['items']) as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      originalText: map['original_text'],
      imagePath: map['image_path'],
      audioPath: map['audio_path'],
      notes: map['notes'],
      metadata: map['metadata'] != null ? jsonDecode(map['metadata']) : null,
    );
  }

  Future close() async {
    final db = await instance.database;
    await db.close();
  }
}
