import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_exe/bloc/transaction_bloc.dart';
import 'package:wallet_exe/data/dao/transaction_table.dart';
import 'package:wallet_exe/data/model/Transaction.dart';
import 'package:wallet_exe/enums/duration_filter.dart';
import 'package:wallet_exe/pages/records_page.dart';
import 'package:wallet_exe/utils/text_input_formater.dart';

class Cardbalance extends StatefulWidget {
  const Cardbalance({Key? key})
      : super(key: key); // ✅ sửa key nullable và dùng const

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
    final _bloc = Provider.of<TransactionBloc>(context);
    _bloc.initData();

    return StreamBuilder<List<Transaction>>(
        stream: _bloc.transactionListStream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
              final transactions = snapshot.data ?? [];
              final values = TransactionTable().getTotal(
                transactions,
                DurationFilter.valueFromName(_currentOption)!,
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
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Flexible(
                                      child: Container(
                                        height: outComeHeight,
                                        width: 40,
                                        color: Colors.red,
                                      ),
                                    ),
                                    const SizedBox(width: 16), // khoảng cách giữa hai cột
                                    Flexible(
                                      child: Container(
                                        height: inComeHeight,
                                        width: 40,
                                        color: Colors.green,
                                      ),
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
                                    Flexible(
                                      child: Text(
                                        '${textToCurrency(inCome.toString())} đ',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Colors.green, fontSize: 18),
                                      ),
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
                                    Flexible(
                                      child: Text(
                                        '${textToCurrency(outCome.toString())} đ',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Colors.red, fontSize: 18),
                                      ),
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
                                    Flexible(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              textToCurrency(
                                                accumulation > 100000000 ||
                                                        accumulation <
                                                            -100000000
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
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  const TextStyle(fontSize: 18),
                                            ),
                                          ),
                                          Text(
                                            accumulation > 100000000 ||
                                                    accumulation < -100000000
                                                ? 'tr đ'
                                                : 'đ',
                                            style:
                                                const TextStyle(fontSize: 18),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                // Thay thế phần Row cuối cùng trong Column bằng code này:

                                Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: _navToRecords,
                                      borderRadius: BorderRadius.circular(8),
                                      splashColor: Colors.blue.withOpacity(0.2),
                                      highlightColor: Colors.blue.withOpacity(0.1),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: const <Widget>[
                                            Text(
                                              "Xem ghi chép",
                                              style: TextStyle(
                                                color: Colors.blue,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              color: Colors.blue,
                                              size: 14,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
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
