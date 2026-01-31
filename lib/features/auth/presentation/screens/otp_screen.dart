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
    if (_formKey.currentState?.validate() ?? false) {
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




  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is OTPLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const AuthLoadingDialog(message: 'Verifying code...'),
          );
        } else if (state is OTPVerified) {
          Navigator.of(context).pop(); // Dismiss loading
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Success'),
              content: const Text('Code verified successfully!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (widget.type == OTPType.forgotPassword) {
                      context.pushRoute(
                        '${AppRouter.resetPassword}?email=${widget.email}&token=${state.response.sessionId ?? ""}',
                      );
                    } else {
                       context.goRoute(AppRouter.login); // Or home
                    }
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else if (state is OTPSent) {
           Navigator.of(context).pop(); // Dismiss loading if it was showing
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Code resent successfully')),
           );
        } else if (state is AuthError) {
          Navigator.of(context).pop(); // Dismiss loading
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Verification Failed'),
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
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Top controls (theme and language toggles)
                    AuthTopControls(),

                    SizedBox(height: isSmall ? 20.h : 40.h),

                    // Content wrapped with CustomFadeIn
                    CustomFadeIn(
                      duration: 600,
                      child: Column(
                        children: [
                          // Title info
                          Column(
                            children: [
                              TextApp(
                                text: context.translate(
                                  LangKeys.otpVerification,
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
                                text: context.translate(LangKeys.otpDescription),
                                textAlign: TextAlign.center,
                                theme: context.textStyle.copyWith(
                                  fontSize: isSmall ? 15.sp : 15.sp,
                                  fontWeight: FontWeight.w400,
                                  color: context.colors.grey?.withOpacity(0.7),
                                ),
                              ),
                            ],
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
                          AuthButton(
                            text: context.translate(LangKeys.verify),
                            onPressed: _onVerifyOTP,
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
                                  color: context.colors.primary!.withOpacity(
                                    0.7,
                                  ),
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
                            text:
                                'Back to ${context.translate(LangKeys.login)}',
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
          ),
        ),
      ),
    );

  }
}
