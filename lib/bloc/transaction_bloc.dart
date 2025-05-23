import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wallet_exe/bloc/base_bloc.dart';
import 'package:wallet_exe/data/dao/spend_limit_table.dart';
import 'package:wallet_exe/data/dao/transaction_table.dart';
import 'package:wallet_exe/data/model/Transaction.dart';
import 'package:wallet_exe/enums/spend_limit_type.dart';
import 'package:wallet_exe/event/transaction_event.dart';
import 'package:wallet_exe/event/base_event.dart';
import 'package:wallet_exe/services/notification_service.dart';
import 'package:wallet_exe/utils/app_preferences.dart';

class TransactionBloc extends BaseBloc {
  TransactionTable _transactionTable = TransactionTable();

  // Đảm bảo StreamController là broadcast và được khởi tạo một lần
  final _transactionListStreamController =
      StreamController<List<Transaction>>.broadcast();

  Stream<List<Transaction>> get transactionListStream =>
      _transactionListStreamController.stream;

  List<Transaction> _transactionListData = [];

  List<Transaction> get transactionListData => _transactionListData;

  void initData() async {
    _transactionListData = await _transactionTable.getAll() ?? [];
    print(
        'TransactionBloc init: Loaded ${_transactionListData.length} transactions');
    if (!_transactionListStreamController.isClosed) {
      _transactionListStreamController.sink.add(_transactionListData);
    }
  }

  _addTransaction(Transaction transaction) async {
    await _transactionTable.insert(transaction);
    _transactionListData.add(transaction);
    if (!_transactionListStreamController.isClosed) {
      _transactionListStreamController.sink.add(_transactionListData);
    }
    await _checkAndNotifyLimit(transaction); // Gọi kiểm tra hạn mức ở đây
  }

  _deleteTransaction(Transaction transaction) async {
    await _transactionTable.delete(transaction.id!);
    _transactionListData.removeWhere((item) => item.id == transaction.id);
    if (!_transactionListStreamController.isClosed) {
      _transactionListStreamController.sink.add(_transactionListData);
    }
  }

  _updateTransaction(Transaction transaction) async {
    await _transactionTable.update(transaction);
    int index = _transactionListData.indexWhere((item) {
      return item.id == transaction.id;
    });
    _transactionListData[index] = transaction;
    if (!_transactionListStreamController.isClosed) {
      _transactionListStreamController.sink.add(_transactionListData);
    }
  }

  void dispatchEvent(BaseEvent event) {
    if (event is AddTransactionEvent) {
      Transaction transaction = Transaction.copyOf(event.transaction);
      _addTransaction(transaction);
    } else if (event is DeleteTransactionEvent) {
      Transaction transaction = Transaction.copyOf(event.transaction);
      _deleteTransaction(transaction);
    } else if (event is UpdateTransactionEvent) {
      Transaction transaction = Transaction.copyOf(event.transaction);
      _updateTransaction(transaction);
    }
  }

  @override
  void dispose() {
    _transactionListStreamController.close();
    super.dispose();
  }

  Future<void> _checkAndNotifyLimit(Transaction transaction) async {
    // Lấy index hạn mức đã chọn
    final selectedIndex = await AppPreferences.getSelectedSpendLimitIndex();
    if (selectedIndex == null) return;

    // Lấy danh sách hạn mức
    final spendLimits = await SpendLimitTable().getAll();
    if (selectedIndex >= spendLimits.length) return;
    final limit = spendLimits[selectedIndex];

    // Lấy tổng chi tiêu theo loại hạn mức (cho tất cả tài khoản)
    final spent = await TransactionTable().getMoneySpendByDuration(limit.type);

    if (spent > limit.amount) {
      await flutterLocalNotificationsPlugin.show(
        0,
        'Vượt hạn mức chi tiêu',
        'Bạn đã vượt hạn mức chi tiêu ${_getTypeText(limit.type)}!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'limit_channel_id',
            'Limit Channel',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        payload: 'limit_exceeded',
      );
    }
  }

  String _getTypeText(SpendLimitType type) {
    switch (type) {
      case SpendLimitType.WEEKLY:
        return 'tuần';
      case SpendLimitType.MONTHLY:
        return 'tháng';
      case SpendLimitType.QUATERLY:
        return 'quý';
      case SpendLimitType.YEARLY:
        return 'năm';
      default:
        return '';
    }
  }
}
