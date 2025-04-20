import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_exe/enums/currency.dart';
import 'package:wallet_exe/enums/language.dart';
import 'package:wallet_exe/services/Sync_service.dart';
import 'package:wallet_exe/themes/theme.dart';
import 'package:wallet_exe/themes/theme_bloc.dart';

class SettingFragment extends StatefulWidget {
  const SettingFragment({Key? key}) : super(key: key); // ✅ Null safety

  @override
  _SettingFragmentState createState() => _SettingFragmentState();
}

class _SettingFragmentState extends State<SettingFragment> {
  Currency _currency = Currency.VIETNAM;
  Language _language = Language.VIETNAM;

  void _submit() {
    final user = FirebaseAuth.instance.currentUser;
    if(user!=null) {
      SyncService().syncToCloud(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final _bloc = Provider.of<ThemeBloc>(context);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            StreamBuilder<AppTheme>(
              stream: _bloc.outTheme,
              builder: (context, snapshot) {
                return ListTile(
                  title: const Text('Thiết đặt màu sắc:'),
                  trailing: DropdownButton<AppTheme>(
                    hint: const Text("Amber"),
                    value: snapshot.data,
                    items: myThemes.map((AppTheme appTheme) {
                      return DropdownMenuItem<AppTheme>(
                        value: appTheme,
                        child: Text(appTheme.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _bloc.inTheme(value); // ✅ dùng như Function
                      }
                    },
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Đơn vị tiền tệ:'),
              trailing: DropdownButton<Currency>(
                value: _currency,
                onChanged: (Currency? value) {
                  if (value != null) {
                    setState(() {
                      _currency = value;
                    });
                  }
                },
                items: Currency.getAllType()
                    .map<DropdownMenuItem<Currency>>((Currency value) {
                  return DropdownMenuItem<Currency>(
                    value: value,
                    child: Text(value.name),
                  );
                }).toList(),
              ),
            ),
            ListTile(
              title: const Text('Ngôn ngữ:'),
              trailing: DropdownButton<Language>(
                value: _language,
                onChanged: (Language? value) {
                  if (value != null) {
                    setState(() {
                      _language = value;
                    });
                  }
                },
                items: Language.getAllType()
                    .map<DropdownMenuItem<Language>>((Language value) {
                  return DropdownMenuItem<Language>(
                    value: value,
                    child: Text(value.name),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 25),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: TextButton(
                      onPressed: _submit,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_download,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              'Đồng bộ dữ liệu',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: TextButton(
                      onPressed: _submit,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.clear_all,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              'Xóa toàn bộ dữ liệu',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
