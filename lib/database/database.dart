import 'dart:async';
import 'dart:io';
import 'package:ept/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    } else {
      _database = await _initDatabase();
      return _database!;
    }
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ept.db');
    // Check if the database already exists
    final exists = await databaseExists(path);
    if (!exists) {
      // Copy from assets
      try {
        await Directory(dirname(path)).create(recursive: true);

        // Load database from the asset bundle
        final data = await rootBundle.load('assets/database/ept.db');
        final bytes = data.buffer.asUint8List();

        // Write the bytes to the local file
        await File(path).writeAsBytes(bytes);
      } catch (e) {
        print('Error copying database: $e');
      }
    }

    // Open the database
    return openDatabase(path);
  }

  Future<List<Map<String, dynamic>>> initMainList(int? year) async {
    final db = await database;
    DateTime now = DateTime.now();
    int yearNow = now.year;
    int yearSelected = year == null || year == 0 ? yearNow : year;
    DateTime customDate = DateTime(yearSelected, 12, 1);
    String currentMonthYear = DateFormat('MM/yyyy').format(customDate);
    String currentYear = DateFormat('yyyy').format(customDate);
    String uniqueID = currentMonthYear;
    final isCurrentMonthExists = await db.rawQuery(
      'SELECT * FROM expense_global WHERE exDate = ?',
      [currentMonthYear],
    );

    if (isCurrentMonthExists.isEmpty) {
      await db.rawInsert(
        'INSERT INTO expense_global (exDate, exTotal, exLastUpdate,exYear,exRefID) VALUES (?, ?, ?, ?, ?)',
        [currentMonthYear, 0, now.toString(), currentYear, uniqueID],
      );
    }

    // Fetch and return all records
    final records = await db
        .rawQuery('SELECT * FROM expense_global WHERE exYear=?', [currentYear]);
    return records;
  }

  Future<List<Map<String, dynamic>>> getExpense(int limit) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT * FROM Worksheet WHERE isShown=? ORDER BY RANDOM() LIMIT ?',
        [0, limit]);
    return result;
  }

  Future<int> upsertExpenseList(
      FormActionType type, ExpenseClass expense) async {
    final db = await database;
    final isCurrentMonthExists = await db.rawQuery(
      'SELECT * FROM expense_global WHERE exRefID = ?',
      [expense.elRefId],
    );
    if (isCurrentMonthExists.isEmpty) {
      DateTime parsedDate = DateFormat('MM/yyyy').parse(expense.elRefId);
      String listYear = DateFormat('yyyy').format(parsedDate);

      await db.rawInsert(
        'INSERT INTO expense_global (exDate, exTotal, exLastUpdate,exYear,exRefID) VALUES (?, ?, ?, ?, ?)',
        [expense.elRefId, 0, expense.elLastUpdate, listYear, expense.elRefId],
      );
    }
    if (type == FormActionType.add) {
      final result = await db.rawInsert(
          'INSERT INTO expense_list (elAmount, elLastUpdate, elRefId, elComment,elCategory) VALUES (?, ?, ?, ?,?)',
          [
            expense.elAmount,
            expense.elLastUpdate,
            expense.elRefId,
            expense.elComment,
            expense.elCategory,
          ]);
      return result;
    } else if (type == FormActionType.update) {
      final result = await db.rawUpdate(
          'UPDATE expense_list SET elAmount=?, elLastUpdate=?, elRefId=?, elComment=?, elCategory=? WHERE elID=?',
          [
            expense.elAmount,
            expense.elLastUpdate,
            expense.elRefId,
            expense.elComment,
            expense.elCategory,
            expense.elID
          ]);
      return result;
    } else if (type == FormActionType.delete) {
      final result = await db
          .rawDelete('DELETE FROM expense_list WHERE elID=?', [expense.elID]);
      return result;
    } else {
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> getExpenseList(String id) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT * FROM expense_list WHERE elRefId=? ORDER BY elLastUpdate DESC',
        [id]);
    return result;
  }

  void updateExpenseGlobalTotalAmount(String refID) async {
    final db = await database;
    final sumOfExpense = await db.rawQuery(
        'SELECT SUM(elAmount) as total from expense_list WHERE elRefId=?',
        [refID]);
    final total = sumOfExpense[0]['total'] ?? 0;
    await db.rawUpdate(
        'UPDATE expense_global SET exTotal=? WHERE exRefID=?', [total, refID]);
  }

  void resetDatabase() async {
    final db = await database;
    await db.rawDelete('DELETE FROM expense_list');
    await db.rawDelete('DELETE FROM expense_global');
    ScaffoldMessenger.of(context as BuildContext).showSnackBar(
      const SnackBar(content: Text('Database reset done')),
    );
  }
}
