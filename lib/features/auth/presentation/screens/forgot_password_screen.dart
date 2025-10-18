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
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(ForgotPasswordEvent(_emailController.text.trim()));
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
        if (state is ForgotPasswordSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.translate(LangKeys.otpSent)),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate to OTP screen
          context.goRoute('${AppRouter.otp}?email=${_emailController.text.trim()}&type=forgotPassword');
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
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 
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

                        SizedBox(height: isSmall ? 16.h : 24.h),

                        // Title info
                        AuthTitleInfo(
                          title: context.translate(LangKeys.forgotPassword),
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
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return context.translate(LangKeys.validEmail);
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: isSmall ? 20.h : 24.h),

                        // Send reset code button
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return AuthButton(
                              text: context.translate(LangKeys.resendCode),
                              onPressed: _onSendResetCode,
                              isLoading: state is AuthLoading,
                            );
                          },
                        ),

                        SizedBox(height: isSmall ? 16.h : 20.h),

                        // Back to login
                        AuthLinkButton(
                          text: '${context.translate(LangKeys.login)}',
                          onPressed: () {
                            context.goRoute(AppRouter.login);
                          },
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
      ),
    );
  }
}