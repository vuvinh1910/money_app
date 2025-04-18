

abstract class AuthEvent {}

class AppStarted extends AuthEvent {} // Khi ứng dụng khởi động
class SignInWithEmail extends AuthEvent {
  final String email;
  final String password;
  SignInWithEmail(this.email, this.password);
}
class SignInWithGoogle extends AuthEvent {}
class RegisterWithEmail extends AuthEvent {
  final String email;
  final String password;
  RegisterWithEmail(this.email, this.password);
}
class SendEmailVerification extends AuthEvent {}
class CheckEmailVerified extends AuthEvent {}
class ResetPassword extends AuthEvent {
  final String email;
  ResetPassword(this.email);
}
class SignOut extends AuthEvent {}