import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';

class ExpensesDb {
  static final ExpensesDb instance = ExpensesDb._init();
  static Database? _database;

  ExpensesDb._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expenses.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        note TEXT,
        date TEXT NOT NULL
      )
    ''');
  }

  // CRUD
  Future<int> insert(Expense expense) async {
    final db = await instance.database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<List<Expense>> getAll() async {
    final db = await instance.database;
    final result = await db.query('expenses', orderBy: 'date DESC');
    return result.map((json) => Expense.fromMap(json)).toList();
  }

  Future<int> update(Expense expense) async {
    final db = await instance.database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAll() async {
    final db = await instance.database;
    await db.delete('expenses');
  }

  Future<double> getTotalByMonth(int year, int month) async {
    final db = await instance.database;

    final firstDay = DateTime(year, month, 1).toIso8601String();
    final firstDayNextMonth = DateTime(year, month + 1, 1).toIso8601String();

    final result = await db.rawQuery(
      '''
      SELECT SUM(amount) as total 
      FROM expenses 
      WHERE date >= ? AND date < ?
    ''',
      [firstDay, firstDayNextMonth],
    );

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}
