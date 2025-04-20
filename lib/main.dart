import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:wallet_exe/services/AuthService.dart';
import 'package:wallet_exe/services/sync_service.dart';
import 'package:wallet_exe/themes/theme_bloc.dart';
import 'package:wallet_exe/widgets/auth_screen.dart';
import 'package:wallet_exe/widgets/verify_email.dart';
import './bloc/account_bloc.dart';
import 'event/auth_event.dart';
import 'event/auth_state.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  await DatabaseHelper.instance.database;

  // Đồng bộ từ cloud khi mở app
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      final start = DateTime.now();
      await SyncService().syncFromCloud(user.uid);
      final end = DateTime.now();
      print('Sync from cloud on app start completed in ${end.difference(start).inMilliseconds}ms');
    } catch (e) {
      print('Error syncing from cloud on app start: $e');
    }
  } else {
    print('No user logged in on app start');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Khởi tạo BLoC
  final accountBloc = AccountBloc();
  final transactionBloc = TransactionBloc();
  final categoryBloc = CategoryBloc();
  final spendLimitBloc = SpendLimitBloc();
  final themeBloc = ThemeBloc();
  final authBloc = AuthBloc(FirebaseAuthService());

  MyApp() {
    // Khởi tạo dữ liệu
    accountBloc.initData();
    transactionBloc.initData();
    categoryBloc.initData();
    spendLimitBloc.initData();
    // Phát sự kiện AppStarted
    authBloc.add(AppStarted());
  }

  @override
  Widget build(BuildContext context) {
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
                return AuthScreen();
              }
            },
          ),
        ),
      ),
    );
  }
}