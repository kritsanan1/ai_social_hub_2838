import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import './widgets/app_logo_widget.dart';
import './widgets/login_form_widget.dart';
import './widgets/signup_link_widget.dart';
import './widgets/social_login_widget.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final bool isSignup;

  const LoginScreen({
    Key? key,
    this.isSignup = false,
  }) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(String email, String password) async {
    if (!_formKey.currentState!.validate()) return;

    final authNotifier = ref.read(authProvider.notifier);
    final success = await authNotifier.signIn(
      email: email,
      password: password,
    );

    if (!mounted) return;

    if (success) {
      // Success - trigger haptic feedback
      HapticFeedback.lightImpact();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('เข้าสู่ระบบสำเร็จ!'),
          backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigate to dashboard
      context.go('/dashboard');
    } else {
      // Error - show error message
      HapticFeedback.mediumImpact();

      final authState = ref.read(authProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.error ?? 'เข้าสู่ระบบไม่สำเร็จ'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _handleSignup(String email, String password, String fullName) async {
    if (!_formKey.currentState!.validate()) return;

    final authNotifier = ref.read(authProvider.notifier);
    final success = await authNotifier.signUp(
      email: email,
      password: password,
      fullName: fullName.isNotEmpty ? fullName : null,
    );

    if (!mounted) return;

    if (success) {
      // Success - trigger haptic feedback
      HapticFeedback.lightImpact();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('สมัครสมาชิกสำเร็จ!'),
          backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigate to onboarding
      context.go('/onboarding');
    } else {
      // Error - show error message
      HapticFeedback.mediumImpact();

      final authState = ref.read(authProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.error ?? 'สมัครสมาชิกไม่สำเร็จ'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _handleSocialLogin(String provider) async {
    if (provider.toLowerCase() == 'google') {
      final authNotifier = ref.read(authProvider.notifier);
      final success = await authNotifier.signInWithGoogle();

      if (!mounted) return;

      if (success) {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เข้าสู่ระบบด้วย ${provider.toUpperCase()} สำเร็จ!'),
            backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/dashboard');
      } else {
        HapticFeedback.mediumImpact();
        final authState = ref.read(authProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.error ?? 'เข้าสู่ระบบไม่สำเร็จ'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$provider login ยังไม่รองรับในขณะนี้'),
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleSignupTap() {
    if (widget.isSignup) {
      context.go('/login');
    } else {
      context.go('/signup');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Column(
                      children: [
                        SizedBox(height: 8.h),

                        // App Logo Section
                        const AppLogoWidget(),

                        SizedBox(height: 6.h),

                        // Login/Signup Form Section
                        if (widget.isSignup)
                          _buildSignupForm(isLoading)
                        else
                          LoginFormWidget(
                            onLogin: _handleLogin,
                            isLoading: isLoading,
                          ),

                        SizedBox(height: 4.h),

                        // Social Login Section
                        SocialLoginWidget(
                          onSocialLogin: _handleSocialLogin,
                          isLoading: isLoading,
                        ),

                        const Spacer(),

                        // Signup/Login Link Section
                        SignupLinkWidget(
                          onSignupTap: _handleSignupTap,
                          isSignup: widget.isSignup,
                        ),

                        SizedBox(height: 2.h),
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

  Widget _buildSignupForm(bool isLoading) {
    return Column(
      children: [
        // Full Name Field
        TextFormField(
          controller: _fullNameController,
          decoration: const InputDecoration(
            labelText: 'ชื่อ-นามสกุล (ไม่บังคับ)',
            prefixIcon: Icon(Icons.person_outline),
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),

        // Email Field
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'อีเมล',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'กรุณากรอกอีเมล';
            }
            if (!value.contains('@')) {
              return 'รูปแบบอีเมลไม่ถูกต้อง';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Password Field
        TextFormField(
          controller: _passwordController,
          decoration: const InputDecoration(
            labelText: 'รหัสผ่าน',
            prefixIcon: Icon(Icons.lock_outline),
          ),
          obscureText: true,
          textInputAction: TextInputAction.done,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'กรุณากรอกรหัสผ่าน';
            }
            if (value.length < 6) {
              return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),

        // Signup Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () => _handleSignup(
                      _emailController.text,
                      _passwordController.text,
                      _fullNameController.text,
                    ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('สมัครสมาชิก'),
          ),
        ),
      ],
    );
  }
}

