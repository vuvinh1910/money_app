import 'package:nimble_charts/flutter.dart' as charts;
import 'package:flutter/material.dart';

class SpendChart extends StatefulWidget {
  final List<charts.Series<dynamic, String>> _seriesList;
  final bool animate;

  const SpendChart(this._seriesList, {this.animate = true, Key? key})
      : super(key: key);

  @override
  State<SpendChart> createState() => _SpendChartState();
}

class _SpendChartState extends State<SpendChart> {
  int? selectedBarIndex;
  Offset? tapPosition;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        tapPosition = details.localPosition;
      },
      child: Stack(
        children: [
          SizedBox(
            height: 200,
            child: charts.BarChart(
              widget._seriesList,
              animate: widget.animate,
              animationDuration: const Duration(milliseconds: 500),
              domainAxis: charts.OrdinalAxisSpec(),
              selectionModels: [
                charts.SelectionModelConfig(
                  type: charts.SelectionModelType.info,
                  changedListener: (charts.SelectionModel model) {
                    if (model.hasDatumSelection) {
                      setState(() {
                        selectedBarIndex = model.selectedDatum[0].index!;
                      });
                    }
                  },
                ),
              ],
              behaviors: [
                charts.SelectNearest(),
                charts.DomainHighlighter(),
              ],
            ),
          ),
          if (selectedBarIndex != null)
            Positioned(
              // Vị trí này chỉ là demo, bạn có thể tính toán lại cho đúng đỉnh cột
              left: 20.0 + (selectedBarIndex! * 25), // Điều chỉnh lại cho đúng
              top: 20,
              child:
                  _buildTooltip(widget._seriesList[0].data[selectedBarIndex!]),
            ),
        ],
      ),
    );
  }

  Widget _buildTooltip(dynamic data) {
    final month = data.month;
    final money = data.money * 1000;
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'Tháng $month\n$money đ',
          style: const TextStyle(color: Colors.white, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class MoneySpend {
  final int month;
  final int money;

  MoneySpend(this.month, this.money);
}
