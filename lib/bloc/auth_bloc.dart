import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';
import '../data/database_helper.dart';
import '../event/auth_event.dart';
import '../event/auth_state.dart';
import '../services/AuthService.dart';
import '../services/Sync_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuthService _authService;

  AuthBloc(this._authService) : super(AuthInitial()) {
    // Xử lý khi ứng dụng khởi động
    on<AppStarted>((event, emit) async {
      emit(AuthLoading());
      final user = _authService.currentUser;
      if (user != null) {
        await _authService.refreshUser();
        if (user.emailVerified || user.providerData.any((info) => info.providerId != 'password')) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthNeedsVerification(user));
        }
      } else {
        emit(AuthUnauthenticated());
      }
    });

    // Đăng nhập bằng email
    on<SignInWithEmail>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await _authService.signInWithEmailAndPassword(event.email, event.password);
        if (user != null) {
          try {
            final syncService = SyncService();
            final start = DateTime.now();
            await syncService.syncFromCloud(user.uid);
            final end = DateTime.now();
            print('Sync after email login completed in ${end.difference(start).inMilliseconds}ms');
          } catch (e) {
            print('Error syncing after email login: $e');
            // Không chặn đăng nhập nếu đồng bộ thất bại
          }
          emit(AuthAuthenticated(user));
        }
      } on FirebaseAuthException catch (e) {
        emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
      }
    });

    on<SignInWithGoogle>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await _authService.signInWithGoogle();
        if (user != null) {
          print('SignInWithGoogle: Đăng nhập thành công - ${user.email}');
          try {
            final syncService = SyncService();
            final start = DateTime.now();
            await syncService.syncFromCloud(user.uid);
            final end = DateTime.now();
            print('Sync after email login completed in ${end.difference(start).inMilliseconds}ms');
          } catch (e) {
            print('Error syncing after email login: $e');
            // Không chặn đăng nhập nếu đồng bộ thất bại
          }
          emit(AuthAuthenticated(user));
        } else {
          print('SignInWithGoogle: Người dùng hủy đăng nhập');
          emit(AuthUnauthenticated());
        }
      } catch (e) {
        print('SignInWithGoogle: Lỗi - $e');
        final errorMessage = e.toString().replaceFirst('Exception: ', '');
        emit(AuthError(errorMessage));
        emit(AuthUnauthenticated());
      }
    });

    // Đăng ký bằng email
    on<RegisterWithEmail>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await _authService.registerWithEmailAndPassword(event.email, event.password);
        if (user != null) {
          emit(AuthNeedsVerification(user));
        }
      } catch (e) {
        emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
      }
    });

    // Gửi email xác minh
    on<SendEmailVerification>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authService.sendEmailVerification();
        final user = _authService.currentUser!;
        emit(AuthNeedsVerification(user));
      } catch (e) {
        emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
      }
    });

    // Kiểm tra email đã xác minh chưa
    on<CheckEmailVerified>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authService.refreshUser();
        final user = _authService.currentUser!;
        if (user.emailVerified) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthNeedsVerification(user));
        }
      } catch (e) {
        emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
      }
    });

    // Khôi phục mật khẩu
    on<ResetPassword>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authService.sendPasswordResetEmail(event.email);
        emit(AuthUnauthenticated()); // Quay lại trạng thái chưa đăng nhập
      } catch (e) {
        emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
      }
    });

    // Đăng xuất
    on<SignOut>((event, emit) async {
      emit(AuthLoading());
      final user = FirebaseAuth.instance.currentUser;
      if(user != null) {
        await SyncService().syncToCloud(user.uid);
      }
      await _clearSQLite();
      print('Cleared SQLite on sign out');
      await _authService.signOut();
      emit(AuthUnauthenticated());
    });
  }

  // Kiểm tra SQLite rỗng
  Future<bool> _isSQLiteEmpty() async {
    final db = await DatabaseHelper.instance.database;
    final tables = ['account', 'category', 'transaction_table', 'spend_limit'];
    for (var table in tables) {
      final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table')) ?? 0;
      if (count > 0) return false;
    }
    return true;
  }

  // Xóa dữ liệu SQLite
  Future<void> _clearSQLite() async {
    final db = await DatabaseHelper.instance.database;
    final tables = ['account', 'category', 'transaction_table', 'spend_limit'];
    final batch = db.batch();
    for (var table in tables) {
      batch.delete(table);
    }
    await batch.commit();
  }
}