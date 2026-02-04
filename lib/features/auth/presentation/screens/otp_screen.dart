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
import '../widgets/auth_button.dart';
import '../widgets/auth_link_button.dart';
import '../widgets/auth_loading_widget.dart';
import '../bloc/auth_bloc.dart';
import '../../domain/entities/otp_request.dart';
import '../../domain/entities/auth_request.dart';

class OTPScreen extends StatefulWidget {
  final String email;
  final OTPType type;
  final AuthRequest? registrationData;

  const OTPScreen({
    super.key,
    required this.email,
    required this.type,
    this.registrationData,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();
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
    _focusNode.dispose();
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
      final otp = _otpController.text.trim();

      if (widget.type == OTPType.registration &&
          widget.registrationData != null) {
        // Complete registration with OTP
        final request = AuthRequest(
          email: widget.registrationData!.email,
          password: widget.registrationData!.password,
          fullName: widget.registrationData!.fullName,
          phoneNumber: widget.registrationData!.phoneNumber,
          otp: otp,
        );
        context.read<AuthBloc>().add(RegisterEvent(request));
      } else {
        // Standard verification (e.g. Forgot Password)
        final request = OTPRequest(
          email: widget.email,
          otp: otp,
          type: widget.type,
        );
        context.read<AuthBloc>().add(VerifyOTPEvent(request));
      }
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
        if (state is OTPLoading || state is AuthLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (context) => AuthLoadingDialog(
                  message:
                      state is OTPLoading
                          ? 'Verifying code...'
                          : 'Completing registration...',
                ),
          );
        } else if (state is OTPVerified) {
          Navigator.of(context).pop(); // Dismiss loading

          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
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
                          context.goRoute(AppRouter.login);
                        }
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
          );
        } else if (state is AuthSuccess) {
          Navigator.of(context).pop(); // Dismiss loading
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Success'),
                  content: const Text(
                    'Account created and signed in successfully!',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.goRoute(AppRouter.home);
                      },
                      child: const Text('Get Started'),
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
            builder:
                (context) => AlertDialog(
                  title: const Text('Action Failed'),
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
                                text: context.translate(
                                  LangKeys.otpDescription,
                                ),
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

                          // OTP Fields
                          SizedBox(
                            height: 60.h,
                            child: Stack(
                              children: [
                                // Hidden Text Field for Input Handling
                                Opacity(
                                  opacity: 0,
                                  child: TextFormField(
                                    controller: _otpController,
                                    focusNode: _focusNode,
                                    keyboardType: TextInputType.number,
                                    maxLength: 6,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return ''; // Return empty string to signal error but don't show text
                                      }
                                      if (value.length != 6) {
                                        return '';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      setState(() {});
                                      if (value.length == 6) {
                                        _onVerifyOTP();
                                      }
                                    },
                                    decoration: const InputDecoration(
                                      counterText: '',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),

                                // Visible Styled Boxes
                                GestureDetector(
                                  onTap: () {
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(_focusNode);
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: List.generate(6, (index) {
                                      final code = _otpController.text;
                                      final isFilled = index < code.length;
                                      final isFocused = index == code.length;

                                      return Container(
                                        width: isSmall ? 40.w : 48.w,
                                        height: isSmall ? 50.h : 56.h,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color:
                                                isFocused
                                                    ? context.colors.primary!
                                                    : isFilled
                                                    ? context.colors.primary!
                                                        .withOpacity(0.5)
                                                    : Colors.grey.withOpacity(
                                                      0.3,
                                                    ),
                                            width: isFocused ? 2 : 1.5,
                                          ),
                                          boxShadow: [
                                            if (isFocused)
                                              BoxShadow(
                                                color: context.colors.primary!
                                                    .withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                          ],
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          isFilled ? code[index] : '',
                                          style: context.textStyle.copyWith(
                                            fontSize: 24.sp,
                                            fontWeight: FontWeight.bold,
                                            color: context.colors.primary,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
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
                                text:
                                    _canResend
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
