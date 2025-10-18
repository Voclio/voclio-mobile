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
import '../../domain/entities/otp_request.dart';

class OTPScreen extends StatefulWidget {
  final String email;
  final OTPType type;

  const OTPScreen({
    super.key,
    required this.email,
    required this.type,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  bool _canResend = true;
  int _resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _startResendCountdown() {
    setState(() {
      _canResend = false;
      _resendCountdown = 60;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _resendCountdown--;
        });
        return _resendCountdown > 0;
      }
      return false;
    }).then((_) {
      if (mounted) {
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  void _onVerifyOTP() {
    if (_formKey.currentState!.validate()) {
      final request = OTPRequest(
        email: widget.email,
        otp: _otpController.text.trim(),
        type: widget.type,
      );
      context.read<AuthBloc>().add(VerifyOTPEvent(request));
    }
  }

  void _onResendOTP() {
    if (_canResend) {
      context.read<AuthBloc>().add(SendOTPEvent(widget.email, widget.type));
      _startResendCountdown();
    }
  }

  Future<void> _onRefresh() async {
    // Clear any previous errors and reset form
    context.read<AuthBloc>().add(RefreshAuthEvent());
    await Future.delayed(const Duration(milliseconds: 500));
  }

  String _getTitle() {
    switch (widget.type) {
      case OTPType.registration:
        return context.translate(LangKeys.otpVerification);
      case OTPType.forgotPassword:
        return context.translate(LangKeys.otpVerification);
      case OTPType.login:
        return context.translate(LangKeys.otpVerification);
    }
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is OTPVerified) {
          if (widget.type == OTPType.forgotPassword) {
            context.goRoute('${AppRouter.resetPassword}?email=${widget.email}');
          } else {
            context.goRoute(AppRouter.home);
          }
        } else if (state is OTPSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.translate(LangKeys.otpSent)),
              backgroundColor: Colors.green,
            ),
          );
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
                        title: _getTitle(),
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

                    SizedBox(height: isSmall ? 24.h : 32.h),

                    // Verify button
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return AuthButton(
                          text: context.translate(LangKeys.verify),
                          onPressed: _onVerifyOTP,
                          isLoading: state is OTPLoading,
                        );
                      },
                    ),

                    SizedBox(height: isSmall ? 20.h : 24.h),

                    // Resend code
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Didn't receive the code? ",
                          style: context.textStyle.copyWith(
                            fontSize: isSmall ? 12.sp : 14.sp,
                            color: context.colors.textColor!.withOpacity(0.7),
                          ),
                        ),
                        AuthLinkButton(
                          text: _canResend 
                              ? context.translate(LangKeys.resendCode)
                              : 'Resend in ${_resendCountdown}s',
                          onPressed: _canResend ? _onResendOTP : null,
                        ),
                      ],
                    ),

                    SizedBox(height: isSmall ? 12.h : 16.h),

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
