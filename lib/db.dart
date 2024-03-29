import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class Expense {
  int? id;
  final String title;
  final int amount;
  final DateTime date;

  Expense(this.title, this.amount, this.date);

  Expense.row(this.id, this.title, this.amount, this.date);

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'expenses.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE expenses(id INTEGER PRIMARY KEY, title TEXT, amount INTEGER, date DATETIME)',
        );
      },
      version: 1,
    );
  }

  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return db.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Expense>> getExpenses() async {
    final db = await database;
    final List<Map<String, dynamic>> allMaps = await db.query('expenses');
    DateTime now = DateTime.now();
    int currentMonth = now.month;
    int currentYear = now.year;
    List<Map<String, dynamic>> filteredMaps = allMaps.where((expense) {
      DateTime expenseDate = DateTime.parse(expense['date']);
      return expenseDate.month == currentMonth &&
          expenseDate.year == currentYear;
    }).toList();
    filteredMaps.sort((a, b) {
      DateTime dateA = DateTime.parse(a['date']);
      DateTime dateB = DateTime.parse(b['date']);
      return dateB.compareTo(dateA); // Compare in descending order
    });
    List<Expense> expenses = [];
    for (var map in filteredMaps) {
      Expense expense = Expense.row(
        map['id'],
        map['title'],
        map['amount'],
        DateTime.parse(map['date']),
      );
      expenses.add(expense);
    }
    return expenses;
  }

  Future<void> deleteExpenseById(int id) async {
    final db = await database;
    await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, int>> getTotalExpenseByMonth() async {
    final Database db = await database;

    List<Map<String, dynamic>> results = await db.rawQuery(
        "SELECT strftime('%Y-%m', date) AS month, SUM(amount) AS total FROM expenses GROUP BY month ORDER BY date DESC");

    Map<String, int> totalExpensesByMonth = {};
    for (Map<String, dynamic> result in results) {
      String month = result['month'] as String;
      int totalExpense = (result['total'] ?? 0);
      totalExpensesByMonth[month] = totalExpense;
    }

    return totalExpensesByMonth;
  }

  Future<void> updateExpense(Expense expense) async {
    final db = await instance.database;
    await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }
}
