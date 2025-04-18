import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../event/auth_event.dart';
import '../event/auth_state.dart';

class VerifyEmailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Xác minh Email')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthNeedsVerification) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Vui lòng xác minh email: ${state.user.email}'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(SendEmailVerification());
                    },
                    child: Text('Gửi lại email xác minh'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(CheckEmailVerified());
                    },
                    child: Text('Tôi đã xác minh'),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(SignOut());
                    },
                    child: Text('Thoát'),
                  ),
                ],
              ),
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}