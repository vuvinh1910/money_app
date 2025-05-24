import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:wallet_exe/bloc/account_bloc.dart'; // Thêm import AccountBloc
import 'package:wallet_exe/bloc/auth_bloc.dart';
import 'package:wallet_exe/bloc/category_bloc.dart';
import 'package:wallet_exe/bloc/spend_limit_bloc.dart';
import 'package:wallet_exe/bloc/transaction_bloc.dart';
import 'package:wallet_exe/data/database_helper.dart';
import 'package:wallet_exe/pages/main_page.dart';
import 'package:wallet_exe/services/AuthService.dart';
import 'package:wallet_exe/services/notification_service.dart';
import 'package:wallet_exe/services/sync_service.dart';
import 'package:wallet_exe/themes/theme_bloc.dart';
import 'package:wallet_exe/widgets/auth_screen.dart';
import 'package:wallet_exe/widgets/verify_email.dart';
import 'package:wallet_exe/themes/theme.dart'; // Đảm bảo import AppTheme và myThemes
import 'event/auth_event.dart';
import 'event/auth_state.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings =
  const Settings(persistenceEnabled: true);
  await DatabaseHelper.instance.database;
  await requestNotificationPermission();
  await initNotifications();

  // Đồng bộ từ cloud khi mở app
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      final start = DateTime.now();
      await SyncService().syncFromCloud(user.uid);
      final end = DateTime.now();
      print(
          'Sync from cloud on app start completed in ${end.difference(start).inMilliseconds}ms');
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
        // Đảm bảo themeBloc được cung cấp ở đây
        Provider<ThemeBloc>.value(value: themeBloc),
        // AuthBloc nên được cung cấp qua BlocProvider nếu bạn dùng flutter_bloc cho nó
      ],
      child: BlocProvider( // Cung cấp AuthBloc bằng BlocProvider
        create: (context) => authBloc,
        // Bao bọc MaterialApp bằng StreamBuilder để lắng nghe themeBloc
        child: StreamBuilder<AppTheme>(
          stream: themeBloc.outTheme,
          // Đặt theme mặc định ban đầu.
          // Đảm bảo myThemes đã được định nghĩa và có ít nhất một phần tử.
          initialData: myThemes[0], // Ví dụ: Amber là theme mặc định ban đầu
          builder: (context, snapshot) {
            final AppTheme currentAppTheme = snapshot.data ?? myThemes[0]; // Fallback nếu snapshot.data là null

            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Wallet Exe',
              // Áp dụng ThemeData từ AppTheme được chọn
              theme: ThemeData(
                brightness: currentAppTheme.theme.brightness,
                primarySwatch: currentAppTheme.theme.primarySwatch,
                // Sử dụng colorScheme để thiết lập secondary (accent) color đúng cách
                colorScheme: ColorScheme.fromSwatch(
                  primarySwatch: currentAppTheme.theme.primarySwatch,
                  brightness: currentAppTheme.theme.brightness,
                ).copyWith(secondary: currentAppTheme.theme.accentColor),
                fontFamily: 'Quicksand',
                visualDensity: VisualDensity.adaptivePlatformDensity,
                // Bạn có thể thêm các tùy chỉnh theme khác ở đây nếu cần
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
                    return Scaffold(
                        body: Center(child: CircularProgressIndicator()));
                  } else if (state is AuthAuthenticated) {
                    return MainPage();
                  } else if (state is AuthNeedsVerification) {
                    return VerifyEmailScreen();
                  } else {
                    return AuthScreen();
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

Future<void> requestNotificationPermission() async {
  final status = await Permission.notification.status;
  if (status.isDenied || status.isPermanentlyDenied) {
    final result = await Permission.notification.request();
    if (result.isGranted) {
      print('Notification permission granted');
    } else {
      print('Notification permission denied');
    }
  } else {
    print('Notification permission already granted');
  }
}