import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Đăng nhập bằng Email và Mật khẩu
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(Duration(seconds: 10));
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Không tìm thấy người dùng với email này';
          break;
        case 'wrong-password':
          message = 'Mật khẩu không đúng';
          break;
        case 'invalid-email':
          message = 'Email không hợp lệ';
          break;
        case 'user-disabled':
          message = 'Tài khoản đã bị vô hiệu hóa';
          break;
        case 'too-many-requests':
          message = 'Quá nhiều yêu cầu. Vui lòng thử lại sau';
          break;
        default:
          message = 'Lỗi đăng nhập: ${e.message}';
      }
      throw FirebaseAuthException(code: e.code, message: message);
    } catch (e) {
      print('Lỗi đăng nhập email: $e');
      throw Exception('Lỗi đăng nhập: $e');
    }
  }

  // Đăng ký bằng Email và Mật khẩu
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(Duration(seconds: 10));
      final user = userCredential.user;
      if (user != null) {
        await user.sendEmailVerification();
        print('Đã gửi email xác minh đến $email');
      }
      return user;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Email đã được sử dụng';
          break;
        case 'weak-password':
          message = 'Mật khẩu quá yếu (ít nhất 6 ký tự)';
          break;
        case 'invalid-email':
          message = 'Email không hợp lệ';
          break;
        default:
          message = 'Lỗi đăng ký: ${e.message}';
      }
      throw FirebaseAuthException(code: e.code, message: message);
    } catch (e) {
      print('Lỗi đăng ký: $e');
      throw Exception('Lỗi đăng ký: $e');
    }
  }

  // Gửi lại email xác minh
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification().timeout(Duration(seconds: 10));
        print('Đã gửi lại email xác minh');
      }
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: 'Lỗi gửi email xác minh: ${e.message}');
    } catch (e) {
      print('Lỗi gửi email xác minh: $e');
      throw Exception('Lỗi gửi email xác minh: $e');
    }
  }

  // Quên mật khẩu
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      if (email.isEmpty) {
        throw FirebaseAuthException(code: 'empty-email', message: 'Vui lòng nhập email');
      }
      await _auth.sendPasswordResetEmail(email: email).timeout(Duration(seconds: 10));
      print('Email khôi phục đã được gửi thành công');
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Không tìm thấy người dùng với email này';
          break;
        case 'invalid-email':
          message = 'Email không hợp lệ';
          break;
        default:
          message = 'Lỗi gửi email: ${e.message}';
      }
      print('Lỗi FirebaseAuthException: ${e.code} - ${e.message}');
      throw FirebaseAuthException(code: e.code, message: message);
    } catch (e) {
      print('Lỗi không xác định: $e');
      throw Exception('Không thể gửi email khôi phục: $e');
    }
  }

  // Đăng nhập bằng Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw Exception('Đăng nhập Google bị hủy');
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential).timeout(Duration(seconds: 10));
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: 'Lỗi đăng nhập Google: ${e.message}');
    } catch (e) {
      print('Lỗi đăng nhập Google: $e');
      throw Exception('Lỗi đăng nhập Google: $e');
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
      await _auth.signOut();
    } catch (e) {
      print('Lỗi đăng xuất: $e');
      throw Exception('Lỗi đăng xuất: $e');
    }
  }

  // Lấy người dùng hiện tại
  User? get currentUser => _auth.currentUser;

  // Stream trạng thái xác thực
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Làm mới trạng thái người dùng
  Future<void> refreshUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload().timeout(Duration(seconds: 10));
        _auth.currentUser;
      }
    } catch (e) {
      print('Lỗi làm mới người dùng: $e');
      throw Exception('Lỗi làm mới người dùng: $e');
    }
  }
}