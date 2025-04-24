import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wallet_exe/data/dao/account_table.dart';
import 'package:wallet_exe/data/dao/category_table.dart';
import 'package:wallet_exe/data/dao/spend_limit_table.dart';
import 'package:wallet_exe/data/dao/transaction_table.dart';
import 'package:wallet_exe/data/database_helper.dart';
import 'package:wallet_exe/data/model/Account.dart';
import 'package:wallet_exe/data/model/Category.dart';
import 'package:wallet_exe/data/model/SpendLimit.dart';
import 'package:wallet_exe/data/model/Transaction.dart' as trans;

class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final AccountTable _accountTable = AccountTable();
  final CategoryTable _categoryTable = CategoryTable();
  final TransactionTable _transactionTable = TransactionTable();
  final SpendLimitTable _spendLimitTable = SpendLimitTable();

  // Đồng bộ bảng account
  Future<void> syncAccountsToCloud(String userId) async {
    try {
      final accounts = await _accountTable.getAllAccount();
      final batch = _firestore.batch();
      final collection = _firestore.collection('users').doc(userId).collection('accounts');

      for (var account in accounts) {
        final docRef = collection.doc(account.id.toString());
        batch.set(docRef, {
          ...account.toMap(),
          'last_sync': DateTime.now().toIso8601String(),
        });
      }
      await batch.commit();
      print('Sync accounts to cloud completed');
    } catch (e) {
      print('Error syncing accounts to cloud: $e');
      throw Exception('Failed to sync accounts: $e');
    }
  }

  Future<void> syncAccountsFromCloud(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('accounts')
          .get();
      final db = await _dbHelper.database;
      final batch = db.batch();

      for (var doc in snapshot.docs) {
        final account = Account.fromMap({
          'id_account': int.parse(doc.id),
          'account_name': doc['account_name'],
          'balance': doc['balance'],
          'type': doc['type'],
          'icon': doc['icon'],
          'img': doc['img'],
        });
        batch.insert('account', account.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit();
      print('Sync accounts from cloud completed');
    } catch (e) {
      print('Error syncing accounts from cloud: $e');
      throw Exception('Failed to sync accounts from cloud: $e');
    }
  }

  // Đồng bộ bảng category
  Future<void> syncCategoriesToCloud(String userId) async {
    try {
      final categories = await _categoryTable.getAll();
      final batch = _firestore.batch();
      final collection = _firestore.collection('users').doc(userId).collection('categories');

      for (var category in categories) {
        final docRef = collection.doc(category.id.toString());
        batch.set(docRef, {
          ...category.toMap(),
          'last_sync': DateTime.now().toIso8601String(),
        });
      }
      await batch.commit();
      print('Sync categories to cloud completed');
    } catch (e) {
      print('Error syncing categories to cloud: $e');
      throw Exception('Failed to sync categories: $e');
    }
  }

  Future<void> syncCategoriesFromCloud(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('categories')
          .get();
      final db = await _dbHelper.database;
      final batch = db.batch();

      for (var doc in snapshot.docs) {
        final category = Category.fromMap({
          'id': int.parse(doc.id),
          'color': doc['color'] is String ? int.parse(doc['color']) : doc['color'],
          'name': doc['name'],
          'type': doc['type'] is String ? int.parse(doc['type']) : doc['type'],
          'icon': doc['icon'] is String ? int.parse(doc['icon']) : doc['icon'],
          'description': doc['description'] ?? '',
        });
        batch.insert('category', category.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit();
      print('Sync categories from cloud completed');
    } catch (e) {
      print('Error syncing categories from cloud: $e');
      throw Exception('Failed to sync categories from cloud: $e');
    }
  }

  // Đồng bộ bảng transaction_table
  Future<void> syncTransactionsToCloud(String userId) async {
    try {
      final transactions = await _transactionTable.getAll();
      final batch = _firestore.batch();
      final collection = _firestore.collection('users').doc(userId).collection('transactions');

      for (var transaction in transactions) {
        final docRef = collection.doc(transaction.id.toString());
        batch.set(docRef, {
          ...transaction.toMap(),
          'last_sync': DateTime.now().toIso8601String(),
        });
      }
      await batch.commit();
      print('Sync transactions to cloud completed');
    } catch (e) {
      print('Error syncing transactions to cloud: $e');
      throw Exception('Failed to sync transactions: $e');
    }
  }

  Future<void> syncTransactionsFromCloud(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .get();
      final db = await _dbHelper.database;
      final batch = db.batch();

      for (var doc in snapshot.docs) {
        final transactionMap = {
          'id_transaction': int.parse(doc.id),
          'date': doc['date'],
          'amount': doc['amount'],
          'description': doc['description'],
          'id_category': doc['id_category'],
          'id_account': doc['id_account'],
        };
        batch.insert('transaction_table', transactionMap, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit();
      print('Sync transactions from cloud completed');
    } catch (e) {
      print('Error syncing transactions from cloud: $e');
      throw Exception('Failed to sync transactions from cloud: $e');
    }
  }

  // Đồng bộ bảng spend_limit
  Future<void> syncSpendLimitsToCloud(String userId) async {
    try {
      final spendLimits = await _spendLimitTable.getAll();
      final batch = _firestore.batch();
      final collection = _firestore.collection('users').doc(userId).collection('spend_limits');

      for (var spendLimit in spendLimits) {
        final docRef = collection.doc(spendLimit.id.toString());
        batch.set(docRef, {
          ...spendLimit.toMap(),
          'last_sync': DateTime.now().toIso8601String(),
        });
      }
      await batch.commit();
      print('Sync spend limits to cloud completed');
    } catch (e) {
      print('Error syncing spend limits to cloud: $e');
      throw Exception('Failed to sync spend limits: $e');
    }
  }

  Future<void> syncSpendLimitsFromCloud(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('spend_limits')
          .get();
      final db = await _dbHelper.database;
      final batch = db.batch();

      for (var doc in snapshot.docs) {
        final spendLimit = SpendLimit.fromMap({
          'id': int.parse(doc.id),
          'amount': doc['amount'],
          'type': doc['type'],
        });
        batch.insert('spend_limit', spendLimit.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit();
      print('Sync spend limits from cloud completed');
    } catch (e) {
      print('Error syncing spend limits from cloud: $e');
      throw Exception('Failed to sync spend limits from cloud: $e');
    }
  }

  // Đồng bộ từ máy lên cloud (SQLite → Firestore)
  Future<void> syncToCloud(String userId) async {
    try {
      final start = DateTime.now();
      await syncAccountsToCloud(userId);
      await syncCategoriesToCloud(userId);
      await syncTransactionsToCloud(userId);
      await syncSpendLimitsToCloud(userId);
      final end = DateTime.now();
      print('Sync to cloud completed in ${end.difference(start).inMilliseconds}ms');
    } catch (e) {
      print('Error syncing to cloud: $e');
      throw Exception('Failed to sync to cloud: $e');
    }
  }

  // Đồng bộ từ cloud về máy (Firestore → SQLite)
  Future<void> syncFromCloud(String userId) async {
    try {
      final start = DateTime.now();
      await syncAccountsFromCloud(userId);
      await syncCategoriesFromCloud(userId);
      await syncTransactionsFromCloud(userId);
      await syncSpendLimitsFromCloud(userId);
      final end = DateTime.now();
      print('Sync from cloud completed in ${end.difference(start).inMilliseconds}ms');
    } catch (e) {
      print('Error syncing from cloud: $e');
      throw Exception('Failed to sync from cloud: $e');
    }
  }

  // Đồng bộ toàn bộ (giữ lại để tương thích)
  Future<void> sync(String userId) async {
    try {
      final start = DateTime.now();
      await syncToCloud(userId);
      await syncFromCloud(userId);
      final end = DateTime.now();
      print('Full sync completed in ${end.difference(start).inMilliseconds}ms');
    } catch (e) {
      print('Error during full sync: $e');
      throw Exception('Failed to sync: $e');
    }
  }
}