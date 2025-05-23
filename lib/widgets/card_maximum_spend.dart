import 'package:flutter/material.dart';
import 'package:wallet_exe/bloc/spend_limit_bloc.dart';
import 'package:wallet_exe/data/model/SpendLimit.dart';
import 'package:wallet_exe/pages/choose_spend_limit_page.dart';
import 'package:wallet_exe/utils/app_preferences.dart';
import 'package:wallet_exe/widgets/item_maximum_spend.dart';

class CardMaximunSpend extends StatefulWidget {
  CardMaximunSpend({Key? key}) : super(key: key);

  @override
  _CardMaximunSpendState createState() => _CardMaximunSpendState();
}

class _CardMaximunSpendState extends State<CardMaximunSpend> {
  int _currentIndex = 1;
  late SpendLimitBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = SpendLimitBloc();
    _bloc.initData();
    AppPreferences.getSelectedSpendLimitIndex().then((value) {
      if (value != null) {
        setState(() {
          _currentIndex = value;
        });
      }
    });
  }

  _chooseSpendLimit() async {
    var temp = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ChooseSpendLimitPage(_currentIndex)),
    );

    if (temp != null) {
      _currentIndex = temp;
      await AppPreferences.saveSelectedSpendLimitIndex(
          _currentIndex); // Lưu lại
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SpendLimit>>(
      stream: _bloc.spendLimitListStream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(
              child: Container(
                width: 100,
                height: 50,
                child: Text('Bạn chưa tạo hạn mức nào'),
              ),
            );
          case ConnectionState.none:
          case ConnectionState.active:
            return Container(
                width: double.infinity,
                padding: EdgeInsets.all(15.0),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Hạn mức chi',
                            style: Theme.of(context).textTheme.titleMedium),
                        IconButton(
                          icon: Icon(Icons.settings),
                          onPressed: _chooseSpendLimit,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    if (snapshot.hasData && snapshot.data!.isNotEmpty)
                      MaximunSpendItem(
                        snapshot.data![_currentIndex],
                        bloc: _bloc,
                      ),
                  ],
                ));
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
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}
