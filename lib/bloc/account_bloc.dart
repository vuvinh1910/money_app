import 'dart:async';

import 'package:wallet_exe/bloc/base_bloc.dart';
import 'package:wallet_exe/data/dao/account_table.dart';
import 'package:wallet_exe/data/model/Account.dart';
import 'package:wallet_exe/event/account_event.dart';
import 'package:wallet_exe/event/base_event.dart';

class AccountBloc extends BaseBloc {
  AccountTable _accountTable = AccountTable();

  StreamController<List<Account>> _accountListStreamController = StreamController<List<Account>>.broadcast();

  Stream<List<Account>> get accountListStream => _accountListStreamController.stream;

  List<Account> _accountListData = [];

  List<Account> get accountListData => _accountListData;

  final _totalBalanceController = StreamController<int>.broadcast();

  Stream<int> get totalBalanceStream => _totalBalanceController.stream;

  void _updateTotalBalance() async {
    final totalStr = await _accountTable.getTotalBalance();
    final total = int.tryParse(totalStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    print('Total balance: $total');
    if (!_totalBalanceController.isClosed) {
      _totalBalanceController.sink.add(total);
    }
  }

  void initData() async {
    _accountListData = await _accountTable.getAllAccount() ?? [];
    print('AccountBloc init: Loaded ${_accountListData.length} accounts');
    if (!_accountListStreamController.isClosed) {
      _accountListStreamController.sink.add(_accountListData);
    }
    _updateTotalBalance(); // GỌI Ở ĐÂY
  }

  _addAccount(Account account) async {
    await _accountTable.insert(account);
    _accountListData.add(account);
    _accountListStreamController.sink.add(_accountListData);
    _updateTotalBalance(); // GỌI Ở ĐÂY
  }

  _deleteAccount(Account account) async {
    await _accountTable.deleteAccount(account);
    _accountListData.removeWhere((item) => item.id == account.id);
    _accountListStreamController.sink.add(_accountListData);
    _updateTotalBalance(); // GỌI Ở ĐÂY
  }

  _updateAccount(Account account) async {
    await _accountTable.updateAccount(account);
    int index = _accountListData.indexWhere((item) {
      return item.name == account.name;
    });
    _accountListData[index] = account;
    _accountListStreamController.sink.add(_accountListData);
    _updateTotalBalance(); // GỌI Ở ĐÂY
  }

  void dispatchEvent(BaseEvent event) {
    if (event is AddAccountEvent) {
      Account account = Account.copyOf(event.account);
      _addAccount(account);
    } else if (event is DeleteAccountEvent) {
      Account account = Account.copyOf(event.account);
      _deleteAccount(account);
    } else if (event is UpdateAccountEvent) {
      Account account = Account.copyOf(event.account);
      _updateAccount(account);
    }
  }

  @override
  void dispose() {
    _accountListStreamController.close();
    super.dispose();
  }
}
