import 'package:flutter/material.dart';
import 'package:nimble_charts/flutter.dart' as charts;
import 'package:wallet_exe/data/dao/transaction_table.dart';
import 'package:wallet_exe/enums/transaction_type.dart';
import 'package:wallet_exe/widgets/item_spend_chart_circle.dart';

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
                    ? SizedBox(
                  height: 320,
                  width: double.infinity,
                  child: SpendChartCircle(_createData(snapshot.data)),
                )
                    : Container(),
                const Text('Đơn vị: VND'),
              ],
            );
          }

          return const SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(),
          );
        },
      ),
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
        data.add(list[i]);
        data[i].color = colors[i];
      } else if (data.length == 6) {
        last.money += list[i].money;
        if (i == list.length - 1) {
          data.add(last);
        }
      }
    }

    return [
      charts.Series<CategorySpend, String>(
        id: 'CategorySpend',
        domainFn: (CategorySpend spend, _) => spend.category,
        measureFn: (CategorySpend spend, _) => spend.money,
        colorFn: (CategorySpend spend, _) =>
            charts.ColorUtil.fromDartColor(spend.color),
        labelAccessorFn: (CategorySpend spend, _) => spend.money.toString(),
        data: data,
      )
    ];
  }
}

class CategorySpend {
  String category;
  int money;
  Color color;

  CategorySpend(this.category, this.money, [this.color = Colors.grey]);
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
        Text(_item.category),
      ],
    );
  }
}
