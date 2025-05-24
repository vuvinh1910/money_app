import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_exe/bloc/transaction_bloc.dart';
import 'package:wallet_exe/data/model/Transaction.dart';
import 'package:wallet_exe/enums/transaction_type.dart';
import 'package:wallet_exe/utils/text_input_formater.dart';
import 'package:wallet_exe/pages/update_transaction_page.dart'; // Import the UpdateTransactionPage

class RecordsPage extends StatelessWidget {
  const RecordsPage({Key? key}) : super(key: key);

  List<Widget> _createList(List<Transaction> items, BuildContext context) {
    // Sort by date
    items.sort((a, b) {
      return b.date.compareTo(a.date);
    });

    List<Widget> list = [];
    for (int i = 0; i < items.length; i++) {
      list.add(ListTile(
        leading: Icon(items[i].category.icon),
        title: Text(items[i].category.name),
        subtitle: Text('${items[i].date.day}/${items[i].date.month}'),
        trailing: Text(
          textToCurrency(items[i].amount.toString()),
          style: TextStyle(
            color: items[i].category.transactionType == TransactionType.EXPENSE
                ? Colors.red
                : Colors.green,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          // Navigate to UpdateTransactionPage when tapped
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UpdateTransactionPage(items[i]),
            ),
          );
        },
      ));

      // if (items[i].description.trim() != "") {
      //   list.add(Divider());
      //   list.add(Text(items[i].description));
      // }

      if (i != items.length - 1) {
        list.add(Divider());
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    var bloc = Provider.of<TransactionBloc>(context);
    bloc.initData();

    return Scaffold(
      appBar: AppBar(
        title: Text('Ghi chép gần đây'),
      ),
      body: StreamBuilder<List<Transaction>>(
        stream: bloc.transactionListStream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
              return SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  child: Column(
                    children: <Widget>[
                      Column(
                        children: _createList(snapshot.data ?? [], context),
                      ),
                    ],
                  ),
                ),
              );
            case ConnectionState.waiting:
              return Center(
                child: Container(
                  width: 100,
                  height: 50,
                  child: Text('Empty list'),
                ),
              );
            case ConnectionState.none:
            default:
              return Center(
                child: Container(
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
}