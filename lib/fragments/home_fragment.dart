import 'package:flutter/material.dart';
import 'package:wallet_exe/data/dao/account_table.dart';
import 'package:wallet_exe/data/model/Account.dart';
import 'package:wallet_exe/pages/balance_detail_page.dart';
import 'package:wallet_exe/utils/text_input_formater.dart';
import 'package:wallet_exe/widgets/card_balance.dart';
import 'package:wallet_exe/widgets/card_maximum_spend.dart';
import 'package:wallet_exe/widgets/card_spend_chart.dart';
import 'package:provider/provider.dart';
import 'package:wallet_exe/bloc/account_bloc.dart';

class HomeFragment extends StatefulWidget {
  HomeFragment({Key? key}) : super(key: key);

  @override
  _HomeFragmentState createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> {
  @override
  void initState() {
    super.initState();
  }

  _balanceDetailNav() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BalanceDetailPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accountBloc = Provider.of<AccountBloc>(context);
    accountBloc.initData();

    return Container(
      child: Column(
        children: <Widget>[
          Container(
            color: Theme.of(context).primaryColor,
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.all(18.0),
              child: Container(
                width: double.infinity,
                height: 70,
                // .setHeight(170),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.blueGrey
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: InkWell(
                      onTap: _balanceDetailNav,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          CircleAvatar(
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            child: Icon(
                              Icons.attach_money,
                              size: 30,
                              color: Theme.of(context).canvasColor,
                            ),
                          ),
                          StreamBuilder<int>(
                            stream: accountBloc.totalBalanceStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Center(
                                    child: Text(snapshot.error.toString()));
                              } else if (snapshot.hasData) {
                                return Text(
                                  textToCurrency(snapshot.data.toString()),
                                  style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).primaryColor),
                                );
                              }
                              return Container(
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator(),
                              );
                            },
                          ),
                          Icon(
                            Icons.navigate_next,
                            size: 30,
                            color: Theme.of(context).primaryColor,
                          )
                        ],
                      ),
                    )),
              ),
            ),
          ),
          Cardbalance(),
          SizedBox(
            height: 15,
          ),
          CardMaximunSpend(),
          SizedBox(
            height: 15,
          ),
          CardSpendChart(),
          SizedBox(
            height: 60,
          ),
        ],
      ),
    );
  }
}
