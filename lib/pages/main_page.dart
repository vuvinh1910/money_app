import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_exe/bloc/account_bloc.dart'; // Giữ lại import này nếu các fragment cần
import 'package:wallet_exe/fragments/account_fragment.dart';
import 'package:wallet_exe/fragments/chart_fragment.dart';
import 'package:wallet_exe/fragments/home_fragment.dart';
import 'package:wallet_exe/fragments/setting_fragment.dart';
import 'package:wallet_exe/fragments/transaction_fragment.dart';
import 'package:wallet_exe/pages/add_account_page.dart';
import 'package:wallet_exe/pages/new_transaction_page.dart';

import '../bloc/auth_bloc.dart';
import '../event/auth_event.dart';

class DrawerItem {
  final String title;
  final IconData icon;

  const DrawerItem(this.title, this.icon);
}

class MainPage extends StatefulWidget {
  final int index;

  const MainPage({Key? key, this.index = 0}) : super(key: key);

  final drawerItems = const [
    DrawerItem("Tổng quan", Icons.home),
    DrawerItem("Các giao dịch", Icons.account_balance_wallet),
    DrawerItem("Danh sách tài khoản", Icons.view_list),
    DrawerItem("Biểu đồ", Icons.pie_chart),
    DrawerItem("Cài đặt", Icons.settings),
    DrawerItem("Đăng xuất", Icons.logout),
  ];

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _selectedDrawerIndex;

  @override
  void initState() {
    super.initState();
    _selectedDrawerIndex = widget.index;
  }

  Widget _getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return HomeFragment();
      case 1:
        return TransactionFragment();
      case 2:
        return AccountFragment();
      case 3:
        return ChartFragment();
      case 4:
        return const SettingFragment();
      default:
        return const Text("Lỗi: Không tìm thấy mục");
    }
  }

  void _logout() {
    context.read<AuthBloc>().add(SignOut());
  }

  void _onSelectItem(int index) {
    if (index == 5) {
      _logout();
    } else {
      setState(() {
        _selectedDrawerIndex = index;
      });
      Navigator.of(context).pop(); // đóng drawer
    }
  }

  void _actionAddAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddAccountPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final drawerOptions = <Widget>[];
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'Chưa đăng nhập';

    for (var i = 0; i < widget.drawerItems.length; i++) {
      final item = widget.drawerItems[i];
      drawerOptions.add(
        ListTile(
          leading: Icon(item.icon),
          title: Text(item.title),
          selected: i == _selectedDrawerIndex,
          onTap: () => _onSelectItem(i),
        ),
      );
      if (i == 3) {
        drawerOptions.add(const Divider());
      }
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewTransactionPage()),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      appBar: AppBar(
        title: Text(widget.drawerItems[_selectedDrawerIndex].title),
        actions: _selectedDrawerIndex == 2
            ? <Widget>[
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _actionAddAccount,
                ),
              ]
            : null,
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.brown,
                child: Text(
                  email.isNotEmpty
                      ? email[0].toUpperCase()
                      : '?', // Kiểm tra email rỗng
                  style: TextStyle(fontSize: 25),
                ),
              ),
              accountEmail: Text(email),
              accountName: null,
            ),
            Column(children: drawerOptions),
          ],
        ),
      ),
      // ***** PHẦN SỬA ĐỔI CHÍNH *****
      // Loại bỏ Provider.value ở đây. Các widget con sẽ
      // tự động lấy BLoC từ Provider ở MyApp.
      body: SingleChildScrollView(
        child: _getDrawerItemWidget(_selectedDrawerIndex),
      ),
      // *******************************
    );
  }
}
