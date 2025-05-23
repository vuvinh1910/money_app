import 'package:flutter/material.dart';
import 'package:wallet_exe/bloc/transaction_bloc.dart';
import 'package:wallet_exe/data/model/Transaction.dart';
import 'package:wallet_exe/enums/transaction_type.dart';
import 'package:wallet_exe/utils/text_input_formater.dart';
import 'package:wallet_exe/widgets/item_spend_chart.dart';
import 'package:nimble_charts/flutter.dart' as charts;

class CardEarnChart extends StatefulWidget {
  final bool showDetail;

  CardEarnChart({this.showDetail = false});

  @override
  _CardEarnChartState createState() => _CardEarnChartState();
}

class _CardEarnChartState extends State<CardEarnChart> {
  DateTime selectedDate = DateTime.now();

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
    }
  }

  @override
  Widget build(BuildContext context) {
    final _bloc = TransactionBloc();
    _bloc.initData();

    Widget _detailContent(int totalYear) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Trung bình tháng:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${textToCurrency((totalYear / DateTime.now().month).round().toString())} đ',
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Tổng thu nhập:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text('${textToCurrency(totalYear.toString())} đ'),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
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
      child: StreamBuilder(
        stream: _bloc.transactionListStream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
              final List<Transaction> transactions =
              snapshot.data as List<Transaction>;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Thu nhập năm nay',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      TextButton(
                        onPressed: () => _selectDate(context),
                        child: Row(
                          children: const <Widget>[
                            Text('Chọn năm'),
                            SizedBox(width: 5),
                            Icon(Icons.create, size: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('(Đơn vị: VND)'),
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: SpendChart(_getData(transactions)),
                  ),
                  widget.showDetail
                      ? _detailContent(_getTotal(transactions))
                      : const SizedBox(height: 10),
                ],
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
        },
      ),
    );
  }

  int _getTotal(List<Transaction> list) {
    final now = DateTime.now();
    int total = 0;
    for (final transaction in list) {
      if (transaction.date.year == now.year &&
          transaction.category.transactionType == TransactionType.INCOME) {
        total += transaction.amount;
      }
    }
    return total;
  }

  List<charts.Series<MoneySpend, String>> _getData(List<Transaction> list) {
    List<int> totalByMonth = [];
    int totalMonth = 0;
    int flagMonth = 1;

    list.sort((a, b) => a.date.compareTo(b.date));
    list = list
        .where((item) =>
    item.category.transactionType == TransactionType.INCOME &&
        item.date.year == selectedDate.year)
        .toList();

    for (int i = 0; i < list.length; i++) {
      while (flagMonth < list[i].date.month) {
        totalByMonth.add((totalMonth / 1000).round());
        totalMonth = 0;
        flagMonth++;
      }
      if (flagMonth == list[i].date.month) {
        totalMonth += list[i].amount;
      }
      if (flagMonth > list[i].date.month) {
        totalByMonth.add((totalMonth / 1000).round());
      }
      if (i > 0 && i == list.length - 1) {
        totalByMonth.add((totalMonth / 1000).round());
      }
    }

    while (flagMonth <= 12) {
      totalByMonth.add(0);
      flagMonth++;
    }

    final data = List.generate(
      totalByMonth.length,
          (index) => MoneySpend(index + 1, totalByMonth[index]),
    );

    return [
      charts.Series<MoneySpend, String>(
        id: 'MoneySpend',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        domainFn: (MoneySpend spend, _) => spend.month.toString(),
        measureFn: (MoneySpend spend, _) => spend.money,
        data: data,
      ),
    ];
  }
}
