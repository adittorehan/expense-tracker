import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class Expense {
  final String title;
  final int amount;
  final String date;

  Expense(this.title, this.amount, this.date);

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'date': date,
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
          'CREATE TABLE expenses(id INTEGER PRIMARY KEY, title TEXT, amount INTEGER, date TEXT)',
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
    final List<Map<String, dynamic>> maps = await db.query('expenses');
    return List.generate(maps.length, (i) {
      return Expense(
        maps[i]['title'],
        maps[i]['amount'],
        maps[i]['date'],
      );
    });
  }
}
