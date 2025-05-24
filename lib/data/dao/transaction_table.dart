import 'package:sqflite/sqflite.dart';
import 'package:wallet_exe/data/model/Transaction.dart' as trans;
import 'package:wallet_exe/enums/duration_filter.dart';
import 'package:wallet_exe/enums/spend_limit_type.dart';
import 'package:wallet_exe/enums/transaction_type.dart';
import 'package:wallet_exe/widgets/item_spend_chart_circle.dart';

import '../database_helper.dart';
import '../model/Account.dart';
import '../model/Category.dart';

class TransactionTable {
  final tableName = 'transaction_table';
  final id = 'id_transaction';
  final date = 'date';
  final amount = 'amount';
  final description = 'description';
  final idCategory = 'id_category';
  final idAccount = 'id_account';

  void onCreate(Database db, int version) {
    db.execute('CREATE TABLE $tableName('
        '$id INTEGER PRIMARY KEY,'
        '$date TEXT NOT NULL,'
        '$amount INTEGER NOT NULL,'
        '$description TEXT,'
        '$idCategory INTEGER NOT NULL,'
        '$idAccount INTEGER NOT NULL)');
  }

  Future<List<trans.Transaction>> getAll() async {
    final Database db = await DatabaseHelper.instance.database;

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        transaction_table.id_transaction, transaction_table.date, transaction_table.amount,
        transaction_table.description, transaction_table.id_category, transaction_table.id_account,

        account.id_account AS account_id, account.account_name, account.balance,
        account.type AS account_type, account.icon AS account_icon, account.img,

        category.id AS category_id, category.color, category.name,
        category.type AS category_type, category.icon AS category_icon, category.description AS category_description

      FROM transaction_table
      JOIN account ON transaction_table.id_account = account.id_account
      JOIN category ON transaction_table.id_category = category.id
    ''');

    return List.generate(maps.length, (index) {
      final map = maps[index];

      return trans.Transaction(
        id: map['id_transaction'],
        amount: map['amount'],
        date: DateTime.parse(map['date']),
        description: map['description'] ?? '',

        account: Account.fromMap({
          'id_account': map['account_id'], // ✅ Dùng alias đã đặt: 'account_id'
          'account_name': map['account_name'],
          'balance': map['balance'],
          'type': map['account_type'],
          'icon': map['account_icon'],
          'img': map['img'],
        }),

        category: Category.fromMap({
          'id': map['category_id'], // ✅ Dùng alias đã đặt: 'category_id'
          'name': map['name'],
          'color': map['color'],
          'type': map['category_type'],
          'icon': map['category_icon'],
          'description': map['category_description'] ?? '',
        }),
      );
    });
  }

  //get income, outcome per duration
  List<int> getTotal(
      List<trans.Transaction> list, DurationFilter durationFilter) {
    List<int> result = [];
    int income = 0;
    int outcome = 0;
    for (int i = 0; i < list.length; i++) {
      if (DurationFilter.checkValidInDurationFromNow(
          list[i].date, durationFilter)) {
        if (list[i].category.transactionType == TransactionType.INCOME)
          income += list[i].amount;
        if (list[i].category.transactionType == TransactionType.EXPENSE)
          outcome += list[i].amount;
      }
    }
    result.add(income);
    result.add(outcome);
    return result;
  }

  Future<int> insert(trans.Transaction transaction) async {
    // Checking backend validation
    transaction.checkValidationAndThrow();

    // Get a reference to the database.
    final Database db = await DatabaseHelper.instance.database;

    // Insert the TransactionModel into the table. Also specify the 'conflictAlgorithm'.
    // In this case, if the same category is inserted multiple times, it replaces the previous data.
    return await db.insert(
      tableName,
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> delete(int transactionId) async {
    // Get a reference to the database.
    final Database db = await DatabaseHelper.instance.database;

    return db.delete(tableName, where: id + '=?', whereArgs: [transactionId]);
  }

  Future<void> update(trans.Transaction transaction) async {
    final Database db = await DatabaseHelper.instance.database;
    await db.update(tableName, transaction.toMap(),
        where: '$id = ?', whereArgs: [transaction.id]);
  }

  Future<List<CategorySpend>> getAmountSpendPerCategory(
      TransactionType type) async {
    final Database db = await DatabaseHelper.instance.database;
    int typeid = type.value;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
        'select category.name as name, sum(amount) as sum from category, transaction_table where category.id = transaction_table.id_category and category.type = $typeid GROUP by category.id ORDER by sum DESC');
    return List.generate(maps.length, (index) {
      return CategorySpend(maps[index]['name'], maps[index]['sum']);
    });
  }

  Future<int> getMoneySpendByDuration(SpendLimitType type) async {
    int result = 0;
    final Database db = await DatabaseHelper.instance.database;
    // ✅ Sửa câu truy vấn để liệt kê và alias các cột rõ ràng
    List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT
        transaction_table.id_transaction, transaction_table.date, transaction_table.amount,
        transaction_table.description, transaction_table.id_category, transaction_table.id_account,

        account.id_account AS account_id, account.account_name, account.balance,
        account.type AS account_type, account.icon AS account_icon, account.img,

        category.id AS category_id, category.color, category.name,
        category.type AS category_type, category.icon AS category_icon, category.description AS category_description

      FROM transaction_table
      JOIN account ON transaction_table.id_account = account.id_account
      JOIN category ON transaction_table.id_category = category.id
    ''');
    List<trans.Transaction> list = List.generate(maps.length, (index) {
      return trans.Transaction.fromMap(maps[index]);
    });
    list = list
        .where(
            (item) => item.category.transactionType == TransactionType.EXPENSE)
        .toList();

    final now = DateTime.now();

    if (type == SpendLimitType.MONTHLY) {
      for (var t in list) {
        if (t.date.year == now.year && t.date.month == now.month) {
          result += t.amount;
        }
      }
    } else if (type == SpendLimitType.WEEKLY) {
      // Tuần bắt đầu từ thứ 2
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(Duration(days: 6));
      for (var t in list) {
        if (!t.date.isBefore(weekStart) && !t.date.isAfter(weekEnd)) {
          result += t.amount;
        }
      }
    } else if (type == SpendLimitType.YEARLY) {
      for (var t in list) {
        if (t.date.year == now.year) {
          result += t.amount;
        }
      }
    } else if (type == SpendLimitType.QUATERLY) {
      // Quý hiện tại
      int currentQuarter = ((now.month - 1) ~/ 3) + 1;
      for (var t in list) {
        int tQuarter = ((t.date.month - 1) ~/ 3) + 1;
        if (t.date.year == now.year && tQuarter == currentQuarter) {
          result += t.amount;
        }
      }
    }
    return result;
  }
}
