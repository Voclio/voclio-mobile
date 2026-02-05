import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';
import 'package:voclio_app/core/routes/App_routes.dart';
import 'package:voclio_app/core/common/dialogs/voclio_dialog.dart';
import 'package:voclio_app/features/widget_config/presentation/bloc/widget_config_cubit.dart';
import 'package:voclio_app/features/widget_config/presentation/widgets/widget_setup_dialog.dart';

import '../../../../core/common/inputs/text_app.dart';
import '../../../../core/language/lang_keys.dart';
import '../../../../core/styles/fonts/font_weight_helper.dart';
import '../../../../core/common/animation/animate_do.dart';
import '../widgets/auth_top_controls.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_phone_field.dart';
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
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _fullPhoneNumber = '';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is RegistrationPending) {
          // Registration initiated, OTP sent - navigate to OTP screen
          final request = AuthRequest(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: _nameController.text.trim(),
            phoneNumber:
                _fullPhoneNumber.isNotEmpty
                    ? _fullPhoneNumber
                    : _phoneController.text.trim(),
          );

          context.pushRoute(
            '${AppRouter.otp}?email=${_emailController.text.trim()}&type=registration',
            extra: request,
          );
        } else if (state is AuthSuccess) {
          // Check if widget setup should be shown
          final widgetConfigCubit = context.read<WidgetConfigCubit>();
          if (widgetConfigCubit.shouldShowSetupDialog()) {
            // Show widget setup dialog
            WidgetSetupDialog.show(context, cubit: widgetConfigCubit).then((_) {
              // Navigate to home after dialog is closed
              if (context.mounted) {
                context.goRoute(AppRouter.home);
              }
            });
          } else {
            context.goRoute(AppRouter.home);
          }
        } else if (state is AuthError) {
          // Check if it's a duplicate email error
          final message = state.message.toLowerCase();
          final isDuplicateEmail =
              message.contains('already') ||
              message.contains('exists') ||
              message.contains('registered') ||
              message.contains('conflict') ||
              message.contains('taken');

          if (isDuplicateEmail) {
            VoclioDialog.show(
              context: context,
              title: 'Email Already Registered',
              message:
                  'This email is already registered. Please login or use a different email.',
              type: VoclioDialogType.warning,
              primaryButtonText: 'Go to Login',
              secondaryButtonText: 'Try Different Email',
              onPrimaryPressed: () {
                context.read<AuthBloc>().add(RefreshAuthEvent());
                Navigator.of(context).pop();
                context.goRoute(AppRouter.login);
              },
              onSecondaryPressed: () => Navigator.of(context).pop(),
            );
          } else {
            VoclioDialog.showError(
              context: context,
              title: 'Registration Failed',
              message: state.message,
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmall ? 12.w : 18.w),
            child: Column(
              children: [
                SizedBox(height: 8.h),
                AuthTopControls(),
                SizedBox(height: isSmall ? 16.h : 24.h),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: CustomFadeIn(
                      duration: 600,
                      child: Column(
                        children: [
                          TextApp(
                            text: context.translate(LangKeys.createAccount),
                            textAlign: TextAlign.center,
                            theme: context.textStyle.copyWith(
                              fontSize: isSmall ? 22.sp : 26.sp,
                              fontWeight: FontWeightHelper.bold,
                              color: context.colors.primary,
                            ),
                          ),

                          SizedBox(height: isSmall ? 12.h : 16.h),

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
                                      return context.translate(
                                        LangKeys.validName,
                                      );
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: isSmall ? 12.h : 14.h),

                                AuthTextField(
                                  label: context.translate(LangKeys.email),
                                  hint: context.translate(LangKeys.email),
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return context.translate(
                                        LangKeys.validEmail,
                                      );
                                    }
                                    if (!RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                    ).hasMatch(value)) {
                                      return context.translate(
                                        LangKeys.validEmail,
                                      );
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: isSmall ? 12.h : 14.h),

                                AuthPhoneField(
                                  label: 'Phone Number',
                                  hint: 'Enter phone number',
                                  controller: _phoneController,
                                  initialCountryCode: 'EG', // Default to Egypt
                                  onChanged: (phone) {
                                    _fullPhoneNumber = phone.completeNumber;
                                  },
                                  validator: (phone) {
                                    if (phone == null || phone.number.isEmpty) {
                                      return 'Please enter your phone number';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: isSmall ? 12.h : 14.h),

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
                                    if (value == null ||
                                        value.isEmpty ||
                                        value.length < 8) {
                                      return 'Password must be at least 8 characters';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: isSmall ? 12.h : 14.h),

                                AuthTextField(
                                  label: context.translate(
                                    LangKeys.passwordConfirmation,
                                  ),
                                  hint: context.translate(
                                    LangKeys.passwordConfirmation,
                                  ),
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
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
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
                                SizedBox(height: isSmall ? 16.h : 20.h),

                                BlocBuilder<AuthBloc, AuthState>(
                                  builder: (context, state) {
                                    final isLoading =
                                        state is AuthLoading ||
                                        state is OTPLoading;
                                    return AuthButton(
                                      text: context.translate(LangKeys.signUp),
                                      onPressed: isLoading ? null : _onRegister,
                                      isLoading: isLoading,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: isSmall ? 16.h : 20.h),

                          Row(
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
                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      // Step 1: Call register to check for existence and send OTP.
      final request = AuthRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
        phoneNumber:
            _fullPhoneNumber.isNotEmpty
                ? _fullPhoneNumber
                : _phoneController.text.trim(),
      );
      context.read<AuthBloc>().add(RegisterEvent(request));
    }
  }
}
