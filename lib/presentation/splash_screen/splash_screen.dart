import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _loadingAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _loadingOpacityAnimation;

  bool _isInitializing = true;
  String _loadingText = 'กำลังเริ่มต้น...';
  double _progress = 0.0;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startInitialization();
  }

  void _initializeAnimations() {
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _loadingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _loadingOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingAnimationController,
      curve: Curves.easeIn,
    ));

    _logoAnimationController.forward();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _loadingAnimationController.forward();
      }
    });
  }

  Future<void> _startInitialization() async {
    try {
      // Step 1: Check authentication status
      await _updateProgress(0.2, 'ตรวจสอบสถานะการเข้าสู่ระบบ...');
      await Future.delayed(const Duration(milliseconds: 500));
      final bool isAuthenticated = await _checkAuthenticationStatus();

      // Step 2: Load user preferences
      await _updateProgress(0.4, 'โหลดการตั้งค่าผู้ใช้...');
      await Future.delayed(const Duration(milliseconds: 400));
      await _loadUserPreferences();

      // Step 3: Fetch Airshare API configuration
      await _updateProgress(0.6, 'เชื่อมต่อ Airshare API...');
      await Future.delayed(const Duration(milliseconds: 600));
      final bool apiConfigured = await _fetchAirshareConfig();

      // Step 4: Prepare cached social media data
      await _updateProgress(0.8, 'เตรียมข้อมูลโซเชียลมีเดีย...');
      await Future.delayed(const Duration(milliseconds: 500));
      await _prepareCachedData();

      // Step 5: Complete initialization
      await _updateProgress(1.0, 'เสร็จสิ้น');
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      // Navigate based on authentication status and API configuration
      if (!apiConfigured) {
        _showRetryOption();
      } else if (isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/content-calendar');
      } else {
        final bool isFirstTime = await _checkFirstTimeUser();
        if (isFirstTime) {
          Navigator.pushReplacementNamed(context, '/onboarding-flow');
        } else {
          Navigator.pushReplacementNamed(context, '/login-screen');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'เกิดข้อผิดพลาดในการเริ่มต้นแอป';
        });
        _showRetryOption();
      }
    }
  }

  Future<void> _updateProgress(double progress, String text) async {
    if (mounted) {
      setState(() {
        _progress = progress;
        _loadingText = text;
      });
    }
  }

  Future<bool> _checkAuthenticationStatus() async {
    // Simulate checking stored authentication token
    await Future.delayed(const Duration(milliseconds: 300));
    // Mock authentication check - in real app, check SharedPreferences or secure storage
    return false; // Return false for demo to show login flow
  }

  Future<void> _loadUserPreferences() async {
    // Simulate loading user preferences from SharedPreferences
    await Future.delayed(const Duration(milliseconds: 200));
    // Load theme preferences, language settings, etc.
  }

  Future<bool> _fetchAirshareConfig() async {
    // Simulate API configuration check with timeout
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      // Mock API connectivity check
      return true; // Return true for successful configuration
    } catch (e) {
      return false;
    }
  }

  Future<void> _prepareCachedData() async {
    // Simulate preparing cached social media data
    await Future.delayed(const Duration(milliseconds: 300));
    // Load cached posts, user profiles, analytics data, etc.
  }

  Future<bool> _checkFirstTimeUser() async {
    // Check if user has completed onboarding
    await Future.delayed(const Duration(milliseconds: 100));
    return true; // Return true for demo to show onboarding flow
  }

  void _showRetryOption() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _hasError) {
        setState(() {
          _hasError = true;
        });
      }
    });
  }

  void _retryInitialization() {
    setState(() {
      _hasError = false;
      _errorMessage = '';
      _progress = 0.0;
      _loadingText = 'กำลังเริ่มต้น...';
    });
    _startInitialization();
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _loadingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.primaryColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.lightTheme.primaryColor,
              AppTheme.lightTheme.primaryColor.withValues(alpha: 0.8),
              AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Section
              Expanded(
                flex: 3,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _logoAnimationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScaleAnimation.value,
                        child: Opacity(
                          opacity: _logoOpacityAnimation.value,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // App Logo
                              Container(
                                width: 25.w,
                                height: 25.w,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4.w),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: CustomIconWidget(
                                    iconName: 'hub',
                                    color: AppTheme.lightTheme.primaryColor,
                                    size: 12.w,
                                  ),
                                ),
                              ),
                              SizedBox(height: 3.h),
                              // App Name
                              Text(
                                'AI Social Hub',
                                style: AppTheme
                                    .lightTheme.textTheme.headlineMedium
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              // Tagline
                              Text(
                                'จัดการโซเชียลมีเดียด้วย AI',
                                style: AppTheme.lightTheme.textTheme.bodyLarge
                                    ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Loading Section
              Expanded(
                flex: 1,
                child: AnimatedBuilder(
                  animation: _loadingAnimationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _loadingOpacityAnimation.value,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Loading Indicator
                          _hasError
                              ? _buildErrorSection()
                              : _buildLoadingSection(),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Spacing
              SizedBox(height: 5.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSection() {
    return Column(
      children: [
        // Progress Bar
        Container(
          width: 60.w,
          height: 0.8.h,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(1.h),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(1.h),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
        SizedBox(height: 2.h),

        // Loading Text
        Text(
          _loadingText,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 1.h),

        // Progress Percentage
        Text(
          '${(_progress * 100).toInt()}%',
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.6),
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorSection() {
    return Column(
      children: [
        // Error Icon
        CustomIconWidget(
          iconName: 'error_outline',
          color: Colors.white,
          size: 8.w,
        ),
        SizedBox(height: 2.h),

        // Error Message
        Text(
          _errorMessage.isNotEmpty ? _errorMessage : 'ไม่สามารถเชื่อมต่อได้',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 3.h),

        // Retry Button
        ElevatedButton(
          onPressed: _retryInitialization,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.lightTheme.primaryColor,
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2.w),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: 'refresh',
                color: AppTheme.lightTheme.primaryColor,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'ลองใหม่',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
