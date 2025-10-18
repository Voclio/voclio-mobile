import 'package:flutter/material.dart';
import 'package:voclio_app/core/common/widjets/App_gradient.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';
import '../refactor/login_body_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      body: AppGradientBackground(
        useSafeArea: false,
        child: LoginBodyScreen(),
      ),
    );
  }
}
