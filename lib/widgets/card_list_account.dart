import 'package:flutter/material.dart';
import 'package:wallet_exe/bloc/account_bloc.dart';
import 'package:wallet_exe/data/dao/account_table.dart';
import 'package:wallet_exe/data/model/Account.dart';
import 'package:wallet_exe/enums/account_type.dart';
import 'package:wallet_exe/widgets/item_account.dart';

class CardListAccount extends StatefulWidget {
  CardListAccount({Key? key}) : super(key: key);

  @override
  _CardListAccountState createState() => _CardListAccountState();
}

class _CardListAccountState extends State<CardListAccount> {
  _createListAccountTile(List<Account> listAccount) {
    return listAccount.map((account) => ItemAccount(account)).toList();
  }

  @override
  Widget build(BuildContext context) {
    AccountBloc bloc = AccountBloc();
    bloc.initData();

    return StreamBuilder<List<Account>>(
      stream: bloc.accountListStream,
      builder: (context, snapshot) {
        var accountList = snapshot.data ?? [];

        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(
              child: Container(
                width: 100,
                height: 50,
                child: Text('Bạn chưa tạo tài khoản nào'),
              ),
            );

          case ConnectionState.active:
            return Container(
              width: double.infinity,
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
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    child: ExpansionTile(
                      title: Text(
                        "Đang sử dụng (" +
                            AccountTable.getTotalByType(accountList, AccountType.SPENDING) +
                            " đ)",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      initiallyExpanded: true,
                      children: _createListAccountTile(
                        accountList.where((item) => item.type == AccountType.SPENDING).toList(),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: ExpansionTile(
                      title: Text(
                        "Tài khoản tiết kiệm (" +
                            AccountTable.getTotalByType(accountList, AccountType.SAVING) +
                            " đ)",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      initiallyExpanded: false,
                      children: _createListAccountTile(
                        accountList.where((item) => item.type == AccountType.SAVING).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            );

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
}
