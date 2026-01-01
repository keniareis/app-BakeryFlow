import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/sale_model.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sales.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        pagamento TEXT NOT NULL,
        valor REAL NOT NULL,
        data INTEGER NOT NULL
      )
    ''');
  }

  // ================= CRUD =================

  Future<int> insertSale(Sale sale) async {
    final db = await database;
    return await db.insert('sales', sale.toMap());
  }

  Future<List<Sale>> getSalesByDay(
    DateTime date, {
    String pagamento = 'Todos',
  }) async {
    final db = await instance.database;

    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    String where = 'data >= ? AND data < ?';
    List<Object?> whereArgs = [
      start.millisecondsSinceEpoch,
      end.millisecondsSinceEpoch,
    ];

    if (pagamento != 'Todos') {
      where += ' AND pagamento = ?';
      whereArgs.add(pagamento);
    }

    final result = await db.query(
      'sales',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'data DESC',
    );

    return result.map((e) => Sale.fromMap(e)).toList();
  }


  Future<void> deleteSale(int id) async {
    final db = await database;
    await db.delete('sales', where: 'id = ?', whereArgs: [id]);
  }
}
