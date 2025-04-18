import 'package:flutter/material.dart';
import 'package:wallet_exe/bloc/account_bloc.dart';
import 'package:wallet_exe/bloc/transaction_bloc.dart';
import 'package:wallet_exe/data/dao/account_table.dart';
import 'package:wallet_exe/data/model/Transaction.dart';
import 'package:wallet_exe/widgets/card_transaction.dart';

class TransactionFragment extends StatefulWidget {
  const TransactionFragment({Key? key}) : super(key: key); // ✅ null safety

  @override
  _TransactionFragmentState createState() => _TransactionFragmentState();
}

class _TransactionFragmentState extends State<TransactionFragment> {
  DateTime selectedDate = DateTime.now(); // ✅ đã khởi tạo mặc định
  String _currentOption = "Tất cả"; // ✅ khởi tạo trực tiếp để tránh lỗi non-nullable

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      print(selectedDate);
    }
  }

  List<DropdownMenuItem<String>> _getDropDownMenuItems(List<String> snapshotData) {
    return snapshotData
        .map((option) => DropdownMenuItem<String>(
      value: option,
      child: Text(option),
    ))
        .toList();
  }

  List<Widget> _createListCardTransaction(List<Transaction> list) {
    List<Widget> result = [];
    List<Transaction> filter = list;

    if (_currentOption != "Tất cả") {
      filter = list.where((item) => item.account.name == _currentOption).toList();
    }

    // nếu người dùng chọn 1 ngày cụ thể
    if (selectedDate.day != DateTime.now().day ||
        selectedDate.month != DateTime.now().month ||
        selectedDate.year != DateTime.now().year) {
      filter = filter
          .where((item) =>
      item.date.year == selectedDate.year &&
          item.date.month == selectedDate.month &&
          item.date.day == selectedDate.day)
          .toList();
      result.add(CardTransaction(filter, selectedDate));
      return result;
    }

    // ngược lại: hiển thị 7 ngày gần nhất
    var tempFilter = filter;
    DateTime flagDate = DateTime.now();
    for (int i = 0; i < 7; i++) {
      filter = tempFilter
          .where((item) =>
      item.date.year == flagDate.year &&
          item.date.month == flagDate.month &&
          item.date.day == flagDate.day)
          .toList();
      result.add(CardTransaction(filter, flagDate));
      result.add(const SizedBox(height: 15));
      flagDate = flagDate.subtract(const Duration(days: 1));
    }

    return result;
  }

  void changedDropDownItem(String? selectedOption) {
    if (selectedOption != null) {
      setState(() {
        _currentOption = selectedOption;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final blocAccount = AccountBloc();
    final blocTransaction = TransactionBloc();
    blocAccount.initData();
    blocTransaction.initData();

    return StreamBuilder<List<Transaction>>(
      stream: blocTransaction.transactionListStream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.active:
            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              'Tài khoản:',
                              style: Theme.of(context).textTheme.titleMedium, // ✅ thay subtitle1 bằng titleMedium
                            ),
                            const SizedBox(width: 10),
                            FutureBuilder<List<String>>(
                              future: AccountTable().getAllAccountName(),
                              builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot2) {
                                if (snapshot2.hasError) {
                                  return Text(snapshot2.error.toString());
                                } else if (snapshot2.hasData) {
                                  return DropdownButton<String>(
                                    value: _currentOption,
                                    items: _getDropDownMenuItems(snapshot2.data!),
                                    onChanged: changedDropDownItem, // ✅ đúng kiểu
                                  );
                                }
                                return const SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: CircularProgressIndicator(),
                                );
                              },
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () => _selectDate(context),
                          child: Row(
                            children: const <Widget>[
                              Text('Tìm ngày'),
                              SizedBox(width: 5),
                              Icon(Icons.create, size: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (snapshot.hasData)
                    Column(
                      children: _createListCardTransaction(snapshot.data!),
                    )
                  else
                    const Center(
                      child: Text("Không có dữ liệu giao dịch"),
                    )
                ],
              ),
            );

          case ConnectionState.waiting:
            return const Center(
              child: SizedBox(
                width: 100,
                height: 50,
                child: Text('Bạn chưa có giao dịch nào'),
              ),
            );
          case ConnectionState.none:
          default:
            return const Center(
              child: SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(),
              ),
            );
        }
      },
    );
  }
}
