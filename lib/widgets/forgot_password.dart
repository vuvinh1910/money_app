import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../event/auth_event.dart';
import '../event/auth_state.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  String _errorMessage = 'Vui lòng nhập email'; // Lỗi mặc định khi mở màn hình

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Khi màn hình mở, hiển thị thông báo lỗi nếu email chưa được nhập
    _emailController.addListener(() {
      if (_emailController.text.isEmpty) {
        setState(() {
          _errorMessage = 'Vui lòng nhập email';
        });
      } else {
        setState(() {
          _errorMessage = ''; // Nếu có email, thì không có lỗi
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quên Mật Khẩu'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
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
                Text(
                  'Nhập email của bạn để nhận liên kết đặt lại mật khẩu',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: _errorMessage.isEmpty ? null : _errorMessage,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 20),
                state is AuthLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: () {
                    final email = _emailController.text.trim();
                    if (email.isEmpty) {
                      setState(() {
                        _errorMessage = 'Vui lòng nhập email';
                      });
                      return;
                    }
                    context.read<AuthBloc>().add(ResetPassword(email));
                  },
                  child: Text('Gửi Yêu Cầu'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
