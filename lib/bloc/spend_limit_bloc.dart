import 'dart:async';

import 'package:wallet_exe/bloc/base_bloc.dart';
import 'package:wallet_exe/data/dao/spend_limit_table.dart';
import 'package:wallet_exe/data/model/SpendLimit.dart';
import 'package:wallet_exe/event/spend_limit_event.dart';
import 'package:wallet_exe/event/base_event.dart';

class SpendLimitBloc extends BaseBloc {
  SpendLimitTable _spendLimitTable = SpendLimitTable();

  StreamController<List<SpendLimit>> _spendLimitListStreamController =
      StreamController<List<SpendLimit>>.broadcast();

  Stream<List<SpendLimit>> get spendLimitListStream =>
      _spendLimitListStreamController.stream;

  List<SpendLimit> _spendLimitListData = [];

  List<SpendLimit> get spendLimitListData => _spendLimitListData;

  void initData() async {
    _spendLimitListData = await _spendLimitTable.getAll() ?? [];
    print(
        'SpendLimitBloc init: Loaded ${_spendLimitListData.length} spend limits');
    if (!_spendLimitListStreamController.isClosed) {
      _spendLimitListStreamController.sink.add(_spendLimitListData);
    }
  }

  _addSpendLimit(SpendLimit spendLimit) async {
    _spendLimitTable.insert(spendLimit);

    _spendLimitListData.add(spendLimit);
    _spendLimitListStreamController.sink.add(_spendLimitListData);
  }

  _deleteSpendLimit(SpendLimit spendLimit) async {
    _spendLimitTable.delete(spendLimit.id!);

    _spendLimitListData.remove(spendLimit);
    _spendLimitListStreamController.sink.add(_spendLimitListData);
  }

  _updateSpendLimit(SpendLimit spendLimit) async {
    await _spendLimitTable.update(spendLimit);
    int index = _spendLimitListData.indexWhere((item) {
      return item.id == spendLimit.id;
    });
    if (index != -1) {
      _spendLimitListData[index] = spendLimit;
      _spendLimitListStreamController.sink.add(_spendLimitListData);
    }
  }

  void dispatchEvent(BaseEvent event) {
    if (event is AddSpendLimitEvent) {
      SpendLimit spendLimit = SpendLimit.copyOf(event.spendLimit);
      _addSpendLimit(spendLimit);
    } else if (event is DeleteSpendLimitEvent) {
      SpendLimit spendLimit = SpendLimit.copyOf(event.spendLimit);
      _deleteSpendLimit(spendLimit);
    } else if (event is UpdateSpendLimitEvent) {
      SpendLimit spendLimit = SpendLimit.copyOf(event.spendLimit);
      _updateSpendLimit(spendLimit);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
