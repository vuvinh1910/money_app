import 'package:flutter/material.dart';
import 'package:nimble_charts/flutter.dart' as charts;
import 'package:wallet_exe/data/dao/transaction_table.dart';
import 'package:wallet_exe/enums/transaction_type.dart';

import 'item_spend_chart_circle.dart';

class CardOutcomeChart extends StatefulWidget {
  const CardOutcomeChart({Key? key}) : super(key: key);

  @override
  _CardOutcomeChartState createState() => _CardOutcomeChartState();
}

class _CardOutcomeChartState extends State<CardOutcomeChart> {
  final List<String> _option = ["Hôm nay", "Tuần này", "Tháng này", "Năm nay"];
  late List<DropdownMenuItem<String>> _dropDownMenuItems;
  late String _currentOption;

  @override
  void initState() {
    super.initState();
    _dropDownMenuItems = getDropDownMenuItems();
    _currentOption = "Tháng này";
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    return _option.map((option) {
      return DropdownMenuItem<String>(
        value: option,
        child: Text(option),
      );
    }).toList();
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
      child: FutureBuilder(
        future: TransactionTable()
            .getAmountSpendPerCategory(TransactionType.EXPENSE),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else if (snapshot.hasData) {
            return Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Biểu đồ chi',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    DropdownButton<String>(
                      value: _currentOption,
                      items: _dropDownMenuItems,
                      onChanged: changedDropDownItem,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                snapshot.data.length > 1
                    ? Container(
                  height: 320,
                  width: double.infinity,
                  child: _buildPieChart(_createData(snapshot.data)),
                )
                    : Container(
                  height: 100,
                  child: Center(
                    child: Text("Không có dữ liệu chi tiêu"),
                  ),
                ),
                const Text('Đơn vị: VND'),
              ],
            );
          }

          return const Center(
            child: SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPieChart(List<charts.Series<CategorySpend, String>> seriesList) {
    return charts.PieChart<String>(
      seriesList,
      animate: true,
      defaultRenderer: charts.ArcRendererConfig(
        arcWidth: 60,
        arcRendererDecorators: [
          charts.ArcLabelDecorator(
            labelPosition: charts.ArcLabelPosition.outside,
          ),
        ],
      ),
      behaviors: [
        charts.DatumLegend(
          position: charts.BehaviorPosition.end,
          outsideJustification: charts.OutsideJustification.middleDrawArea,
          horizontalFirst: false,
          desiredMaxColumns: 1,
          cellPadding: const EdgeInsets.only(right: 4.0, bottom: 4.0),
          entryTextStyle: const charts.TextStyleSpec(
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  static List<charts.Series<CategorySpend, String>> _createData(
      List<CategorySpend> list) {
    final List<Color> colors = [
      Colors.red,
      Colors.pinkAccent,
      Colors.blueAccent,
      Colors.green,
      Colors.purpleAccent,
      Colors.amberAccent,
      Colors.black54,
    ];

    List<CategorySpend> data = [];
    CategorySpend last = CategorySpend("khác", 0);

    for (int i = 0; i < list.length; i++) {
      if (data.length < 6) {
        // Create a new instance to prevent modifying the original list
        CategorySpend item = CategorySpend(
          list[i].category,
          list[i].money, // Convert to double if needed
        );
        item.color = colors[i % colors.length];
        data.add(item);
      } else if (data.length == 6) {
        last.money += list[i].money; // Convert to double if needed
        if (i == list.length - 1) {
          last.color = colors[6 % colors.length];
          data.add(last);
        }
      }
    }

    // Handle empty data case
    if (data.isEmpty) {
      data.add(CategorySpend("Không có dữ liệu", 0, color: Colors.grey));
    }

    return [
      charts.Series<CategorySpend, String>(
        id: 'CategorySpend',
        domainFn: (CategorySpend spend, _) => spend.category,
        measureFn: (CategorySpend spend, _) => spend.money < 0 ? 0 : spend.money,
        colorFn: (CategorySpend spend, _) =>
            charts.ColorUtil.fromDartColor(spend.color),
        labelAccessorFn: (CategorySpend spend, _) => spend.money.toString(),
        data: data,
      )
    ];
  }
}

class CategoryItem extends StatelessWidget {
  final CategorySpend _item;
  const CategoryItem(this._item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 10,
          height: 10,
          child: DecoratedBox(
            decoration: BoxDecoration(color: _item.color),
          ),
        ),
        const SizedBox(width: 5),
        Text(_item.category),
      ],
    );
  }
}