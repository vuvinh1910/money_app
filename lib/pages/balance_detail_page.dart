import 'package:flutter/material.dart';
import 'package:wallet_exe/data/dao/account_table.dart';
import 'package:nimble_charts/flutter.dart' as charts;
import 'package:wallet_exe/data/model/Account.dart';

class BalanceDetail {
  final String accountName;
  double balance;
  Color color;

  BalanceDetail(this.accountName, this.balance, {this.color = Colors.blue});
}

class BalanceDetailPage extends StatelessWidget {
  const BalanceDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Số dư tài khoản'),
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.blueGrey
              : Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0.0, 15.0),
              blurRadius: 15.0,
            ),
          ],
        ),
        child: FutureBuilder(
          future: AccountTable().getAllAccount(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error.toString());
              return Center(child: Text(snapshot.error.toString()));
            } else if (snapshot.hasData) {
              double total = 0;
              for (int i = 0; i < snapshot.data.length; i++) {
                total += snapshot.data[i].balance;
              }

              return Column(
                children: <Widget>[
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    'Các tài khoản',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  total > 0
                      ? Container(
                    height: 320,
                    width: double.infinity,
                    child: _buildPieChart(_createData(snapshot.data)),
                  )
                      : Container(
                    height: 320,
                    width: double.infinity,
                    child: Center(
                      child: Text('Không có dữ liệu để hiển thị'),
                    ),
                  ),
                  Text('Đơn vị: nghìn'),
                ],
              );
            }
            return Container(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPieChart(List<charts.Series<BalanceDetail, String>> seriesList) {
    return charts.PieChart<String>(
      seriesList,
      animate: true,
      // Use a different renderer to avoid the type error
      defaultRenderer: charts.ArcRendererConfig(
        arcWidth: 60,
        arcRendererDecorators: [
          charts.ArcLabelDecorator(
            labelPosition: charts.ArcLabelPosition.outside,
          )
        ],
      ),
      behaviors: [
        charts.DatumLegend(
          position: charts.BehaviorPosition.end,
          outsideJustification: charts.OutsideJustification.middleDrawArea,
          horizontalFirst: false,
          desiredMaxColumns: 1,
          cellPadding: EdgeInsets.only(right: 4.0, bottom: 4.0),
          entryTextStyle: charts.TextStyleSpec(
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  static List<charts.Series<BalanceDetail, String>> _createData(
      List<Account> list) {
    final List<Color> colors = [
      Colors.red,
      Colors.pinkAccent,
      Colors.blueAccent,
      Colors.green,
      Colors.purpleAccent,
      Colors.amberAccent,
      Colors.black54,
    ];

    List<BalanceDetail> data = [];
    BalanceDetail last = BalanceDetail("khác", 0);
    for (int i = 0; i < list.length; i++) {
      if (data.length < 6) {
        BalanceDetail item = BalanceDetail(list[i].name, list[i].balance.toDouble());
        item.color = colors[i % colors.length]; // Use modulo to avoid index out of range
        data.add(item);
      } else if (data.length == 6) {
        last.balance += list[i].balance;
        if (i == list.length - 1) {
          last.color = colors[6];
          data.add(last);
        }
      }
    }

    // Handle empty data case to avoid rendering issues
    if (data.isEmpty) {
      data.add(BalanceDetail("Không có dữ liệu", 0, color: Colors.grey));
    }

    return [
      charts.Series<BalanceDetail, String>(
        id: 'AccountBalance',
        domainFn: (BalanceDetail item, _) => item.accountName,
        measureFn: (BalanceDetail item, _) =>
        item.balance < 0 ? 0 : item.balance,
        colorFn: (BalanceDetail item, _) =>
            charts.ColorUtil.fromDartColor(item.color),
        labelAccessorFn: (BalanceDetail balance, _) => balance.balance.toString(),
        data: data,
      )
    ];
  }
}