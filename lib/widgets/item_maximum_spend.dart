import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:wallet_exe/bloc/spend_limit_bloc.dart';
import 'package:wallet_exe/custom_toolbox/message_label.dart';
import 'package:wallet_exe/data/dao/transaction_table.dart';
import 'package:wallet_exe/data/model/SpendLimit.dart';
import 'package:wallet_exe/enums/spend_limit_type.dart';
import 'package:wallet_exe/pages/spend_limit_page.dart';
import 'package:wallet_exe/utils/text_input_formater.dart';

class MaximunSpendItem extends StatefulWidget {
  final SpendLimit _spendLimit;
  final SpendLimitBloc bloc;

  const MaximunSpendItem(this._spendLimit, {required this.bloc, super.key});

  @override
  State<MaximunSpendItem> createState() => _MaximunSpendItemState();
}

class _MaximunSpendItemState extends State<MaximunSpendItem> {
  String _getTimelineString() {
    final now = DateTime.now();

    switch (widget._spendLimit.type) {
      case SpendLimitType.WEEKLY:
        DateTime firstDay = now.subtract(Duration(days: now.weekday - 1));
        DateTime lastDay = now.add(Duration(days: 7 - now.weekday));
        return '${firstDay.day}/${firstDay.month} - ${lastDay.day}/${lastDay.month}';

      case SpendLimitType.MONTHLY:
        DateTime lastDay = (now.month < 12)
            ? DateTime(now.year, now.month + 1, 0)
            : DateTime(now.year + 1, 1, 0);
        return '1/${now.month} - ${lastDay.day}/${now.month}';

      case SpendLimitType.QUATERLY:
        int th = (now.month / 3).ceil();
        late DateTime firstDay, lastDay;

        switch (th) {
          case 1:
            firstDay = DateTime(now.year, 1, 1);
            lastDay = DateTime(now.year, 3, 31);
            break;
          case 2:
            firstDay = DateTime(now.year, 4, 1);
            lastDay = DateTime(now.year, 6, 30);
            break;
          case 3:
            firstDay = DateTime(now.year, 7, 1);
            lastDay = DateTime(now.year, 9, 30);
            break;
          case 4:
            firstDay = DateTime(now.year, 10, 1);
            lastDay = DateTime(now.year, 12, 31);
            break;
        }

        return '${firstDay.day}/${firstDay.month} - ${lastDay.day}/${lastDay.month}';

      case SpendLimitType.YEARLY:
        return '1/1 - 31/12';

      default:
        return '';
    }
  }

  String _getDaysLeft() {
    final now = DateTime.now();

    switch (widget._spendLimit.type) {
      case SpendLimitType.WEEKLY:
        return (7 - now.weekday).toString();

      case SpendLimitType.MONTHLY:
        DateTime lastDay = (now.month < 12)
            ? DateTime(now.year, now.month + 1, 0)
            : DateTime(now.year + 1, 1, 0);
        return (lastDay.day - now.day).toString();

      case SpendLimitType.QUATERLY:
        int th = ((now.month - 1) ~/ 3) + 1;
        late DateTime lastDay;

        switch (th) {
          case 1:
            lastDay = DateTime(now.year, 3, 31);
            break;
          case 2:
            lastDay = DateTime(now.year, 6, 30);
            break;
          case 3:
            lastDay = DateTime(now.year, 9, 30);
            break;
          case 4:
            lastDay = DateTime(now.year, 12, 31);
            break;
        }

        return lastDay.difference(now).inDays.toString();

      case SpendLimitType.YEARLY:
        final lastDayOfYear = DateTime(now.year, 12, 31);
        return lastDayOfYear.difference(now).inDays.toString();

      default:
        return '';
    }
  }

  EdgeInsets _getMarginBubble(double containerWidth) {
    try {
      final now = DateTime.now();

      if (widget._spendLimit.type == SpendLimitType.WEEKLY) {
        double scale = (now.weekday - 3.5) / 7;
        double offset = (scale * containerWidth * 1.9).abs();
        return scale >= 0
            ? (offset > 20
                ? EdgeInsets.only(left: offset - 20)
                : EdgeInsets.zero)
            : (offset > 20
                ? EdgeInsets.only(right: offset - 20)
                : EdgeInsets.zero);
      }

      DateTime lastDay = (now.month < 12)
          ? DateTime(now.year, now.month + 1, 0)
          : DateTime(now.year + 1, 1, 0);
      double scale = (now.day - lastDay.day / 2 - 0.5) / lastDay.day;
      double offset = (scale * containerWidth * 1.9).abs();
      return scale >= 0
          ? (offset > 20 ? EdgeInsets.only(left: offset - 20) : EdgeInsets.zero)
          : (offset > 20
              ? EdgeInsets.only(right: offset - 20)
              : EdgeInsets.zero);
    } catch (e) {
      return EdgeInsets.zero;
    }
  }

  EdgeInsets _prevent2Lines() {
    final now = DateTime.now();
    DateTime lastDay = (now.month < 12)
        ? DateTime(now.year, now.month + 1, 0)
        : DateTime(now.year + 1, 1, 0);

    if (now.day == 1) return EdgeInsets.only(left: 10);
    if (now.day == lastDay.day) return EdgeInsets.only(right: 10);
    return EdgeInsets.zero;
  }

  @override
  Widget build(BuildContext context) {
    double containerWidth = MediaQuery.of(context).size.width - 30;

    void _nav() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SpendLimitPage(widget._spendLimit, widget.bloc),
        ),
      );
    }

    return StreamBuilder<List<SpendLimit>>(
      stream: widget.bloc.spendLimitListStream,
      builder: (context, spendLimitSnapshot) {
        // Find the current spend limit in the updated list
        SpendLimit currentSpendLimit = widget._spendLimit;
        if (spendLimitSnapshot.hasData) {
          final updatedSpendLimit = spendLimitSnapshot.data!.firstWhere(
            (limit) => limit.id == widget._spendLimit.id,
            orElse: () => widget._spendLimit,
          );
          currentSpendLimit = updatedSpendLimit;
        }

        return FutureBuilder(
          future: TransactionTable()
              .getMoneySpendByDuration(currentSpendLimit.type),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            } else if (snapshot.hasData) {
              final int spent = snapshot.data ?? 0;
              final int remaining = currentSpendLimit.amount - spent;

              return Column(
                children: <Widget>[
                  InkWell(
                    onTap: _nav,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Icon(Icons.fastfood,
                              size: 35, color: Theme.of(context).primaryColor),
                        ),
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(currentSpendLimit.type.name,
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              Text(_getTimelineString()),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                '${textToCurrency(currentSpendLimit.amount.toString())} đ',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    margin: _getMarginBubble(containerWidth),
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: _prevent2Lines(),
                          padding: const EdgeInsets.all(3.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5.0)),
                          ),
                          child: const Text("Hôm nay", maxLines: 1),
                        ),
                        CustomPaint(
                          painter: TrianglePainter(
                            strokeColor:
                                Theme.of(context).colorScheme.secondary,
                            strokeWidth: 10,
                            paintingStyle: PaintingStyle.fill,
                          ),
                          child: const SizedBox(height: 7, width: 7),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      children: [
                        LinearProgressIndicator(
                          backgroundColor: Colors.black12,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            spent >= currentSpendLimit.amount
                                ? Colors.red
                                : spent / currentSpendLimit.amount > 0.8
                                    ? Colors.orange
                                    : Theme.of(context).primaryColor,
                          ),
                          value: spent >= currentSpendLimit.amount
                              ? 1.0
                              : spent / currentSpendLimit.amount,
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('Còn ${_getDaysLeft()} ngày'),
                            Text(textToCurrency(remaining.toString())),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return const SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(),
            );
          },
        );
      },
    );
  }
}
