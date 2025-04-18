import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../event/auth_event.dart';
import '../event/auth_state.dart';
import 'forgot_password.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLogin = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Đăng nhập' : 'Đăng ký')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            print("$state");
          },
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Mật khẩu'),
                  obscureText: true,
                ),
                if (!_isLogin)
                  TextField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(labelText: 'Nhập lại mật khẩu'),
                    obscureText: true,
                  ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_isLogin) {
                      context.read<AuthBloc>().add(SignInWithEmail(
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                      ));
                    } else {
                      if (_passwordController.text.trim() ==
                          _confirmPasswordController.text.trim()) {
                        context.read<AuthBloc>().add(RegisterWithEmail(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        ));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Mật khẩu không trùng khớp')),
                        );
                      }
                    }
                  },
                  child: Text(_isLogin ? 'Đăng nhập' : 'Đăng ký'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                  child: Text(_isLogin
                      ? 'Chưa có tài khoản? Đăng ký'
                      : 'Đã có tài khoản? Đăng nhập'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                    );
                  },
                  child: Text('Quên mật khẩu?'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(SignInWithGoogle());
                  },
                  child: Text('Đăng nhập bằng Google'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
