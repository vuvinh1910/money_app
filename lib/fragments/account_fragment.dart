import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_exe/bloc/account_bloc.dart';
import 'package:wallet_exe/utils/text_input_formater.dart';
import 'package:wallet_exe/widgets/card_list_account.dart';

class AccountFragment extends StatefulWidget {
  const AccountFragment({Key? key}) : super(key: key);

  @override
  _AccountFragmentState createState() => _AccountFragmentState();
}

class _AccountFragmentState extends State<AccountFragment> {
  @override
  Widget build(BuildContext context) {
    final accountBloc = Provider.of<AccountBloc>(context, listen: false);

    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: <Widget>[
          Container(
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
            child: StreamBuilder<int>(
              stream: accountBloc.totalBalanceStream,
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                if (snapshot.hasError) {
                  print('AccountFragment: Error = ${snapshot.error}');
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  return Text(
                    'Tổng: ${textToCurrency(snapshot.data.toString())}đ',
                    style: Theme.of(context).textTheme.bodyLarge,
                  );
                }
                return const SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
          const SizedBox(height: 15),
          CardListAccount(),
        ],
      ),
    );
  }
}