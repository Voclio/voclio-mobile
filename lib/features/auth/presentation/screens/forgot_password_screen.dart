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
import '../widgets/auth_loading_widget.dart';
import '../bloc/auth_bloc.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSendResetCode() {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      context.read<AuthBloc>().add(ForgotPasswordEvent(email));
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
        if (state is AuthLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const AuthLoadingDialog(message: 'Sending reset code...'),
          );
        } else if (state is ForgotPasswordSent) {
          Navigator.of(context).pop(); // Dismiss loading
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Check your email'),
              content: const Text(
                'We have sent a password reset code to your email.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    final email = _emailController.text.trim();
                    context.pushRoute(
                      '${AppRouter.otp}?email=$email&type=forgotPassword',
                    );
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else if (state is AuthError) {
          Navigator.of(context).pop(); // Dismiss loading
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: Text(state.message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: isSmall ? 20.w : 24.w,
                vertical: isSmall ? 16.h : 20.h,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Top controls (theme and language toggles)
                        AuthTopControls(),
                        SizedBox(height: isSmall ? 60.h : 80.h),
                        // Title info wrapped with CustomFadeIn
                        CustomFadeIn(
                          duration: 600,
                          child: Column(
                            children: [
                              // Title info
                              Column(
                                children: [
                                  TextApp(
                                    text: context.translate(
                                      LangKeys.forgotPassword,
                                    ),
                                    textAlign: TextAlign.center,
                                    theme: context.textStyle.copyWith(
                                      fontSize: isSmall ? 24.sp : 30.sp,
                                      fontWeight: FontWeightHelper.bold,
                                      color: context.colors.primary,
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                  TextApp(
                                    text: context.translate(
                                      LangKeys.forgotPasswordDescription,
                                    ),
                                    textAlign: TextAlign.center,
                                    theme: context.textStyle.copyWith(
                                      fontSize: isSmall ? 15.sp : 15.sp,
                                      fontWeight: FontWeight.w400,
                                      color: context.colors.grey?.withOpacity(
                                        0.7,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: isSmall ? 20.h : 24.h),

                              // Email field
                              AuthTextField(
                                label: context.translate(LangKeys.email),
                                hint: context.translate(LangKeys.email),
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return context.translate(LangKeys.validEmail);
                                  }
                                  if (!RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  ).hasMatch(value)) {
                                    return context.translate(LangKeys.validEmail);
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: isSmall ? 20.h : 24.h),

                              // Send reset code button
                              AuthButton(
                                text: context.translate(LangKeys.resendCode),
                                onPressed: _onSendResetCode,
                              ),

                              SizedBox(height: isSmall ? 16.h : 20.h),

                              // Back to login
                              AuthLinkButton(
                                text: '${context.translate(LangKeys.login)}',
                                onPressed: () {
                                  context.goRoute(AppRouter.login);
                                },
                              ),
                            ],
                          ),
                        ),

                        // Spacer to push content up and fill empty space
                        const Spacer(),
                      ],
                    ),
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
