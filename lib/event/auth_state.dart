import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {} // Trạng thái ban đầu
class AuthLoading extends AuthState {} // Đang xử lý
class AuthUnauthenticated extends AuthState {} // Chưa đăng nhập
class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);
}
class AuthNeedsVerification extends AuthState {
  final User user;
  AuthNeedsVerification(this.user);
}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}