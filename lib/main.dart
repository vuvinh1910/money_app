import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:wallet_exe/bloc/auth_bloc.dart';
import 'package:wallet_exe/bloc/category_bloc.dart';
import 'package:wallet_exe/bloc/spend_limit_bloc.dart';
import 'package:wallet_exe/bloc/transaction_bloc.dart';
import 'package:wallet_exe/data/database_helper.dart';
import 'package:wallet_exe/pages/main_page.dart';
import 'package:wallet_exe/themes/theme.dart';
import 'package:wallet_exe/themes/theme_bloc.dart';
import 'package:wallet_exe/widgets/auth_screen.dart';
import 'package:wallet_exe/widgets/verify_email.dart';
import './bloc/account_bloc.dart';
import 'AuthService/AuthService.dart';
import 'event/auth_event.dart';
import 'event/auth_state.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await DatabaseHelper.instance.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Khởi tạo các bloc
    var accountBloc = AccountBloc();
    var transactionBloc = TransactionBloc();
    var categoryBloc = CategoryBloc();
    var spendLimitBloc = SpendLimitBloc();
    var themeBloc = ThemeBloc();
    var authBloc = AuthBloc(FirebaseAuthService());

    // Khởi tạo dữ liệu
    accountBloc.initData();
    transactionBloc.initData();
    categoryBloc.initData();
    spendLimitBloc.initData();

    // Phát sự kiện AppStarted
    authBloc.add(AppStarted());

    return MultiProvider(
      providers: [
        Provider<AccountBloc>.value(value: accountBloc),
        Provider<TransactionBloc>.value(value: transactionBloc),
        Provider<CategoryBloc>.value(value: categoryBloc),
        Provider<SpendLimitBloc>.value(value: spendLimitBloc),
        Provider<ThemeBloc>.value(value: themeBloc),
      ],
      child: BlocProvider(
        create: (context) => authBloc,
        child: MaterialApp(
          title: 'Wallet Exe',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            fontFamily: 'Quicksand',
          ),
          home: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (context, state) {
              if (state is AuthLoading) {
                return Scaffold(body: Center(child: CircularProgressIndicator()));
              } else if (state is AuthAuthenticated) {
                return MainPage();
              } else if (state is AuthNeedsVerification) {
                return VerifyEmailScreen();
              } else {
                return AuthScreen(); // vẫn còn khả năng lắng nghe được AuthError nhờ BlocConsumer
              }
            },
          ),
        ),
      ),
    );
  }
}
