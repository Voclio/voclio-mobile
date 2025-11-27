import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';
import 'package:voclio_app/core/routes/App_routes.dart';

import '../../../../core/common/inputs/text_app.dart';
import '../../../../core/language/lang_keys.dart';
import '../../../../core/styles/fonts/font_weight_helper.dart';
import '../../../../core/common/animation/animate_do.dart';
import '../widgets/auth_top_controls.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_link_button.dart';
import '../bloc/auth_bloc.dart';
import '../../domain/entities/auth_request.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: isSmall ? 12.w : 18.w,
              vertical: 18.h,
            ),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              AuthTopControls(),
              SizedBox(height: isSmall ? 20.h : 40.h),

              CustomFadeIn(
                duration: 600,
                child: Column(
                  children: [
                    TextApp(
                      text: context.translate(LangKeys.createAccount),
                      textAlign: TextAlign.center,
                      theme: context.textStyle.copyWith(
                          fontSize: isSmall ? 24.sp : 30.sp,
                          fontWeight: FontWeightHelper.bold,
                          color: context.colors.primary
                      ),
                    ),

                    SizedBox(height: isSmall ? 15.h : 20.h),

                    Form(
                key: _formKey,
                child: Column(
                  children: [
                    AuthTextField(
                label: context.translate(LangKeys.fullName),
                hint: context.translate(LangKeys.fullName),
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.translate(LangKeys.validName);
                  }
                  return null;
                },
              ),
              SizedBox(height: isSmall ? 16.h : 20.h),

              AuthTextField(
                label: context.translate(LangKeys.email),
                hint: context.translate(LangKeys.email),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.translate(LangKeys.validEmail);
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return context.translate(LangKeys.validEmail);
                  }
                  return null;
                },
              ),
              SizedBox(height: isSmall ? 16.h : 20.h),

              AuthTextField(
                label: context.translate(LangKeys.password),
                hint: context.translate(LangKeys.password),
                controller: _passwordController,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: context.colors.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 6) {
                    return context.translate(LangKeys.validPasswrod);
                  }
                  return null;
                },
              ),
              SizedBox(height: isSmall ? 16.h : 20.h),

              AuthTextField(
                label: context.translate(LangKeys.passwordConfirmation),
                hint: context.translate(LangKeys.passwordConfirmation),
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: context.colors.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              SizedBox(height: isSmall ? 24.h : 32.h),

                    AuthButton(
                      text: context.translate(LangKeys.signUp),
                      onPressed: _onRegister,
                    ),
                  ],
                ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isSmall ? 20.h : 24.h),

              CustomFadeIn(
                duration: 600,
                child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.translate(LangKeys.youHaveAccount),
                    style: context.textStyle.copyWith(
                      fontSize: isSmall ? 12.sp : 14.sp,
                      color: context.colors.grey?.withOpacity(0.7),
                    ),
                  ),
                  AuthLinkButton(
                    text: context.translate(LangKeys.login),
                    onPressed: () {
                      context.goRoute(AppRouter.login);
                    },
                  ),
                ],
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _onRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      final request = AuthRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
      );
      context.read<AuthBloc>().add(RegisterEvent(request));
    }
  }

  Future<void> _onRefresh() async {
    // Clear any previous errors and reset form
    context.read<AuthBloc>().add(RefreshAuthEvent());
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
