import 'package:flutter/material.dart';
import 'package:wallet_exe/bloc/transaction_bloc.dart';
import 'package:wallet_exe/data/dao/transaction_table.dart';
import 'package:wallet_exe/data/model/Transaction.dart';
import 'package:wallet_exe/enums/duration_filter.dart';
import 'package:wallet_exe/pages/records_page.dart';
import 'package:wallet_exe/utils/text_input_formater.dart';

class Cardbalance extends StatefulWidget {
  const Cardbalance({Key? key}) : super(key: key); // ✅ sửa key nullable và dùng const

  @override
  _CardbalanceState createState() => _CardbalanceState();
}

class _CardbalanceState extends State<Cardbalance> {
  final List<String> _option = DurationFilter.getAllType();
  late List<DropdownMenuItem<String>> _dropDownMenuItems; // ✅ dùng `late`
  late String _currentOption;

  @override
  void initState() {
    super.initState();
    _dropDownMenuItems = getDropDownMenuItems();
    _currentOption = DurationFilter.THISMONTH.name;
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    return _option
        .map((option) => DropdownMenuItem(value: option, child: Text(option)))
        .toList();
  }

  void changedDropDownItem(String? selectedOption) {
    if (selectedOption != null) {
      setState(() {
        _currentOption = selectedOption;
      });
    }
  }

  void _navToRecords() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RecordsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    var _bloc = TransactionBloc();
    _bloc.initData();

    return StreamBuilder<List<Transaction>>(
        stream: _bloc.transactionListStream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
              if (snapshot.data == null || snapshot.data!.isEmpty) {
                return const SizedBox(height: 15);
              }

              final values = TransactionTable().getTotal(
                  snapshot.data!, // ✅ chắc chắn không null ở đây
                  DurationFilter.valueFromName(_currentOption)! // ✅ đảm bảo không null
              );

              final inCome = values[0];
              final outCome = values[1];
              final accumulation = inCome - outCome;
              var sum = inCome + outCome;
              if (sum == 0) sum = 1;
              var inComeHeight = inCome / sum * 120 + 5;
              var outComeHeight = outCome / sum * 120 + 5;

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.blueGrey
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0.0, 15.0),
                      blurRadius: 15.0,
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 41,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: SizedBox(
                          height: 190,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Tình hình thu chi',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Container(
                                      height: outComeHeight,
                                      width: 50,
                                      color: Colors.red,
                                    ),
                                    Container(
                                      height: inComeHeight,
                                      width: 50,
                                      color: Colors.green,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 60,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          DropdownButton<String>(
                            value: _currentOption,
                            items: _dropDownMenuItems,
                            onChanged: changedDropDownItem,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      children: const <Widget>[
                                        CircleAvatar(
                                          backgroundColor: Colors.green,
                                          radius: 5.0,
                                        ),
                                        SizedBox(width: 10),
                                        Text('Thu',
                                            style: TextStyle(fontSize: 16)),
                                      ],
                                    ),
                                    Text(
                                      '${textToCurrency(inCome.toString())} đ',
                                      style: const TextStyle(
                                          color: Colors.green, fontSize: 18),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      children: const <Widget>[
                                        CircleAvatar(
                                          backgroundColor: Colors.red,
                                          radius: 5.0,
                                        ),
                                        SizedBox(width: 10),
                                        Text('Chi',
                                            style: TextStyle(fontSize: 16)),
                                      ],
                                    ),
                                    Text(
                                      '${textToCurrency(outCome.toString())} đ',
                                      style: const TextStyle(
                                          color: Colors.red, fontSize: 18),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const Divider(),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    const Text('Tích lũy',
                                        style: TextStyle(fontSize: 16)),
                                    Row(
                                      children: [
                                        Text(
                                          textToCurrency(
                                            accumulation > 100000000 ||
                                                accumulation < -100000000
                                                ? accumulation
                                                .toString()
                                                .substring(
                                                0,
                                                accumulation
                                                    .toString()
                                                    .length -
                                                    6)
                                                : accumulation.toString(),
                                          ),
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                        Text(
                                          accumulation > 100000000 ||
                                              accumulation < -100000000
                                              ? 'tr đ'
                                              : 'đ',
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    InkWell(
                                      onTap: _navToRecords,
                                      child: const Text(
                                        "Xem ghi chép",
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ),
                                    const Icon(Icons.navigate_next,
                                        color: Colors.blue)
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );

            default:
              return const Center(
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(),
                ),
              );
          }
        });
  }
}
