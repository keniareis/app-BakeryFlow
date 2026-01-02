import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/sale_model.dart';
import '../models/expense_model.dart';

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
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
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

    // TABELA DE DESPESAS
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT NOT NULL,
        value REAL NOT NULL,
        date INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE expenses (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          description TEXT NOT NULL,
          value REAL NOT NULL,
          date INTEGER NOT NULL
        )
      ''');
    }

    if (oldVersion < 3) {
      await db.rawUpdate(
        "UPDATE sales SET pagamento = 'Cartao' WHERE pagamento = 'Cartão'"
      );
    }
  }



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

  Future<List<Sale>> getSalesByMonth(
    DateTime date, {
    String pagamento = 'Todos',
  }) async {
    final db = await database;

    final start = DateTime(date.year, date.month, 1);
    final end = DateTime(date.year, date.month + 1, 1);

    String where = 'data >= ? AND data < ?';
    List<Object?> args = [
      start.millisecondsSinceEpoch,
      end.millisecondsSinceEpoch,
    ];

    if (pagamento != 'Todos') {
      where += ' AND pagamento = ?';
      args.add(pagamento);
    }

    final result = await db.query(
      'sales',
      where: where,
      whereArgs: args,
      orderBy: 'data DESC',
    );

    return result.map((e) => Sale.fromMap(e)).toList();
  }

  Future<List<Sale>> getSalesByYear(
    DateTime date, {
    String pagamento = 'Todos',
  }) async {
    final db = await database;

    final start = DateTime(date.year, 1, 1);
    final end = DateTime(date.year + 1, 1, 1);

    String where = 'data >= ? AND data < ?';
    List<Object?> args = [
      start.millisecondsSinceEpoch,
      end.millisecondsSinceEpoch,
    ];

    if (pagamento != 'Todos') {
      where += ' AND pagamento = ?';
      args.add(pagamento);
    }

    final result = await db.query(
      'sales',
      where: where,
      whereArgs: args,
      orderBy: 'data DESC',
    );

    return result.map((e) => Sale.fromMap(e)).toList();
  }


  //expenses
  // INSERIR DESPESA
  Future<int> insertExpense(Expense expense) async {
    final db = await instance.database;
    return await db.insert('expenses', expense.toMap());
  }

  // LISTAR DESPESAS
  Future<List<Expense>> getExpenses() async {
    final db = await instance.database;
    final result = await db.query(
      'expenses',
      orderBy: 'date DESC',
    );

    return result.map((e) => Expense.fromMap(e)).toList();
  }

  // DELETAR DESPESA
  Future<int> deleteExpense(int id) async {
    final db = await instance.database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Expense>> getExpensesByDay(DateTime date) async {
    final db = await database;

    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final result = await db.query(
      'expenses',
      where: 'date >= ? AND date < ?',
      whereArgs: [
        start.millisecondsSinceEpoch,
        end.millisecondsSinceEpoch,
      ],
      orderBy: 'date DESC',
    );

    return result.map((e) => Expense.fromMap(e)).toList();
  }

  Future<List<Expense>> getExpensesByMonth(DateTime date) async {
    final db = await database;

    final start = DateTime(date.year, date.month, 1);
    final end = DateTime(date.year, date.month + 1, 1);

    final result = await db.query(
      'expenses',
      where: 'date >= ? AND date < ?',
      whereArgs: [
        start.millisecondsSinceEpoch,
        end.millisecondsSinceEpoch,
      ],
      orderBy: 'date DESC',
    );

    return result.map((e) => Expense.fromMap(e)).toList();
  }

  Future<List<Expense>> getExpensesByYear(DateTime date) async {
    final db = await database;

    final start = DateTime(date.year, 1, 1);
    final end = DateTime(date.year + 1, 1, 1);

    final result = await db.query(
      'expenses',
      where: 'date >= ? AND date < ?',
      whereArgs: [
        start.millisecondsSinceEpoch,
        end.millisecondsSinceEpoch,
      ],
      orderBy: 'date DESC',
    );

    return result.map((e) => Expense.fromMap(e)).toList();
  }

  // ===================== GANHOS (SOMA) =====================

Future<double> getTotalSalesByDay(DateTime date) async {
  final db = await database;

  final start = DateTime(date.year, date.month, date.day);
  final end = start.add(const Duration(days: 1));

  final result = await db.rawQuery(
    '''
    SELECT SUM(valor) as total
    FROM sales
    WHERE data >= ? AND data < ?
    ''',
    [
      start.millisecondsSinceEpoch,
      end.millisecondsSinceEpoch,
    ],
  );

  return (result.first['total'] as double?) ?? 0.0;
}

Future<double> getTotalSalesByMonth(DateTime date) async {
  final db = await database;

  final start = DateTime(date.year, date.month, 1);
  final end = DateTime(date.year, date.month + 1, 1);

  final result = await db.rawQuery(
    '''
    SELECT SUM(valor) as total
    FROM sales
    WHERE data >= ? AND data < ?
    ''',
    [
      start.millisecondsSinceEpoch,
      end.millisecondsSinceEpoch,
    ],
  );

  return (result.first['total'] as double?) ?? 0.0;
}

Future<double> getTotalSalesByYear(DateTime date) async {
  final db = await database;

  final start = DateTime(date.year, 1, 1);
  final end = DateTime(date.year + 1, 1, 1);

  final result = await db.rawQuery(
    '''
    SELECT SUM(valor) as total
    FROM sales
    WHERE data >= ? AND data < ?
    ''',
    [
      start.millisecondsSinceEpoch,
      end.millisecondsSinceEpoch,
    ],
  );

  return (result.first['total'] as double?) ?? 0.0;
}

}
