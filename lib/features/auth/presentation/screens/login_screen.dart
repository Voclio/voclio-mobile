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
import '../../domain/entities/auth_request.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          // Navigate to home screen
          context.goRoute(AppRouter.home);
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
                  horizontal: isSmall ? 20.w : 16.w,
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

                        SizedBox(height: isSmall ? 20.h : 40.h),

                        // Title info
                        AuthTitleInfo(
                          title: context.translate(LangKeys.login),
                        ),

                        SizedBox(height: isSmall ? 30.h : 40.h),

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

                        SizedBox(height: isSmall ? 16.h : 20.h),

                        // Password field
                        AuthTextField(
                          label: context.translate(LangKeys.password),
                          hint: context.translate(LangKeys.password),
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: context.colors.textColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
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

                        SizedBox(height: isSmall ? 12.h : 16.h),

                        // Forgot password link
                        Align(
                          alignment: Alignment.centerRight,
                          child: AuthLinkButton(
                            text: context.translate(LangKeys.forgotPassword),
                            onPressed: () {
                              context.goRoute(AppRouter.forgotPassword);
                            },
                          ),
                        ),

                        SizedBox(height: isSmall ? 24.h : 32.h),

                        // Login button
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return AuthButton(
                              text: context.translate(LangKeys.login),
                              onPressed: _onLogin,
                              isLoading: state is AuthLoading,
                            );
                          },
                        ),

                        SizedBox(height: isSmall ? 20.h : 24.h),

                        // Register link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              context.translate(LangKeys.youHaveAccount),
                              style: context.textStyle.copyWith(
                                fontSize: isSmall ? 12.sp : 14.sp,
                                color: context.colors.textColor!.withOpacity(0.7),
                              ),
                            ),
                            AuthLinkButton(
                              text: context.translate(LangKeys.createAccount),
                              onPressed: () {
                                context.goRoute(AppRouter.register);
                              },
                            ),
                          ],
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
  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      final request = AuthRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      context.read<AuthBloc>().add(LoginEvent(request));
    }
  }

  Future<void> _onRefresh() async {
    // Clear any previous errors and reset form
    context.read<AuthBloc>().add(RefreshAuthEvent());
    await Future.delayed(const Duration(milliseconds: 500));
  }

}