import 'package:flutter/material.dart';
import 'package:wallet_exe/bloc/transaction_bloc.dart';
import 'package:wallet_exe/data/model/Transaction.dart';
import 'package:wallet_exe/enums/transaction_type.dart';
import 'package:wallet_exe/utils/text_input_formater.dart';
import 'package:wallet_exe/widgets/item_spend_chart.dart';
import 'package:nimble_charts/flutter.dart' as charts;

class CardSpendChart extends StatefulWidget {
  final bool showDetail;

  CardSpendChart({this.showDetail = false, Key? key}) : super(key: key);

  @override
  _CardSpendChartState createState() => _CardSpendChartState();
}

class _CardSpendChartState extends State<CardSpendChart> {
  int selectedYear = DateTime.now().year;

  Future<void> _selectYear(BuildContext context) async {
    final int? picked = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
            width: 300,
            height: 400,
            child: YearPicker(
              firstDate: DateTime(2015),
              lastDate: DateTime(2101),
              initialDate: DateTime(selectedYear),
              selectedDate: DateTime(selectedYear),
              onChanged: (DateTime dateTime) {
                Navigator.pop(context, dateTime.year);
              },
            ),
          ),
        );
      },
    );
    if (picked != null && picked != selectedYear) {
      setState(() {
        selectedYear = picked;
      });
    }
  }

  String _getTitle() {
    String end =
        (selectedYear == DateTime.now().year) ? 'nay' : selectedYear.toString();
    return 'Chi tiêu năm ' + end;
  }

  @override
  Widget build(BuildContext context) {
    var _bloc = TransactionBloc();
    _bloc.initData();

    Widget _detailContent(int totalYear) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
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
                  '${textToCurrency((totalYear / 12).round().toString())} đ',
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Tổng chi:',
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
                        _getTitle(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      TextButton(
                        onPressed: () => _selectYear(context),
                        child: Row(
                          children: const [
                            Text('Chọn năm'),
                            SizedBox(width: 5),
                            Icon(Icons.create, size: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('(Đơn vị: Nghìn)'),
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
    int total = 0;
    for (var transaction in list) {
      if (transaction.date.year == selectedYear &&
          transaction.category.transactionType == TransactionType.EXPENSE) {
        total += transaction.amount;
      }
    }
    return total;
  }

  List<charts.Series<MoneySpend, String>> _getData(List<Transaction> list) {
    List<int> totalByMonth = List.filled(12, 0);

    for (var transaction in list) {
      if (transaction.category.transactionType == TransactionType.EXPENSE &&
          transaction.date.year == selectedYear) {
        totalByMonth[transaction.date.month - 1] += transaction.amount;
      }
    }

    var data = List.generate(totalByMonth.length, (index) {
      return MoneySpend(index + 1, (totalByMonth[index] / 1000).round());
    });

    return [
      charts.Series<MoneySpend, String>(
        id: 'MoneySpend',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (MoneySpend spend, _) => spend.month.toString(),
        measureFn: (MoneySpend spend, _) => spend.money,
        data: data,
        // Hiển thị số tiền trên mỗi cột
        labelAccessorFn: (MoneySpend spend, _) =>
            spend.money > 0 ? '${spend.money}' : '',
      )
    ];
  }
}

class MoneySpend {
  final int month;
  final int money;

  MoneySpend(this.month, this.money);
}
