import 'package:nimble_charts/flutter.dart' as charts;
import 'package:flutter/material.dart';

class SpendChart extends StatelessWidget {
  final List<charts.Series<dynamic, String>> _seriesList;
  final bool animate;

  const SpendChart(this._seriesList, {this.animate = true, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return charts.BarChart(
      _seriesList,
      animate: animate,
      animationDuration: const Duration(milliseconds: 500),
    );
  }
}

class MoneySpend {
  final int month;
  final int money;

  MoneySpend(this.month, this.money);
}
