import 'package:flutter/material.dart';
import '../dao/user_account_table.dart';

class UserAccount {
  int? id; // auto generate & unique

  String name;
  String mail;
  String password;
  int balance;
  Color themeColor;

  UserAccount({
    this.id,
    required this.name,
    required this.mail,
    required this.password,
    this.balance = 0,
    this.themeColor = Colors.amber,
  });

  // getter
  Map<String, dynamic> toMap() {
    return {
      UserAccountTable().id: id,
      UserAccountTable().name: name,
      UserAccountTable().mail: mail,
      UserAccountTable().password: password,
      UserAccountTable().balance: balance,
      UserAccountTable().themeColor: themeColor.value, // Lưu mã màu int
    };
  }

  // setter
  UserAccount.fromMap(Map<String, dynamic> map)
      : id = map[UserAccountTable().id],
        name = map[UserAccountTable().name],
        mail = map[UserAccountTable().mail],
        password = map[UserAccountTable().password],
        balance = map[UserAccountTable().balance],
        themeColor = Color(map[UserAccountTable().themeColor]);
}
