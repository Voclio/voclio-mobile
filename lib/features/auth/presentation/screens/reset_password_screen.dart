import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';
import 'package:voclio_app/core/routes/App_routes.dart';

import '../../../../core/language/lang_keys.dart';
import '../widgets/auth_title_info.dart';
import '../widgets/auth_top_controls.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_link_button.dart';
import '../bloc/auth_bloc.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({
    super.key,
    required this.email,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onResetPassword() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(ResetPasswordEvent(
        widget.email,
        _newPasswordController.text,
        _otpController.text.trim(),
      ));
    }
  }

  Future<void> _onRefresh() async {
    // Clear any previous errors and reset form
    context.read<AuthBloc>().add(RefreshAuthEvent());
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is PasswordResetSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.translate(LangKeys.passwordResetSuccess)),
              backgroundColor: Colors.green,
            ),
          );
          context.goRoute(AppRouter.login);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.colors.accent!.withOpacity(0.15),
                context.colors.primary!.withOpacity(0.08),
                context.colors.background!,
              ],
            ),
          ),
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isSmall ? 20.w : 24.w,
                  vertical: isSmall ? 16.h : 20.h,
                ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Top controls (theme and language toggles)
                    AuthTopControls(),

                    SizedBox(height: isSmall ? 20.h : 40.h),

                     // Title info
                     AuthTitleInfo(
                       title: context.translate(LangKeys.resetPassword),
                     ),

                    SizedBox(height: isSmall ? 30.h : 40.h),

                    // OTP field
                    AuthTextField(
                      label: context.translate(LangKeys.enterOtp),
                      hint: '123456',
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the verification code';
                        }
                        if (value.length != 6) {
                          return 'Please enter a valid 6-digit code';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: isSmall ? 16.h : 20.h),

                    // New password field
                    AuthTextField(
                      label: 'New ${context.translate(LangKeys.password)}',
                      hint: 'New ${context.translate(LangKeys.password)}',
                      controller: _newPasswordController,
                      obscureText: _obscureNewPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                          color: context.colors.textColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureNewPassword = !_obscureNewPassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return context.translate(LangKeys.validPasswrod);
                        }
                        if (value.length < 6) {
                          return context.translate(LangKeys.validPasswrod);
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: isSmall ? 16.h : 20.h),

                    // Confirm password field
                    AuthTextField(
                      label: 'Confirm New ${context.translate(LangKeys.password)}',
                      hint: 'Confirm New ${context.translate(LangKeys.password)}',
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                          color: context.colors.textColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your new password';
                        }
                        if (value != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: isSmall ? 24.h : 32.h),

                    // Reset password button
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return AuthButton(
                          text: context.translate(LangKeys.resetPassword),
                          onPressed: _onResetPassword,
                          isLoading: state is AuthLoading,
                        );
                      },
                    ),

                    SizedBox(height: isSmall ? 20.h : 24.h),

                    // Back to login
                    AuthLinkButton(
                      text: 'Back to ${context.translate(LangKeys.login)}',
                      onPressed: () {
                        context.goRoute(AppRouter.login);
                      },
                    ),
                  ],
                ),
              ),
            ),
            ),
          ),
        ),
      ),
    );
  }
}
