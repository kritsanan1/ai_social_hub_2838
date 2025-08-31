import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/bottom_navigation_widget.dart';
import './widgets/onboarding_page_widget.dart';
import './widgets/page_control_dots_widget.dart';
import './widgets/progress_indicator_widget.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({Key? key}) : super(key: key);

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentPage = 0;
  final int _totalPages = 3;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      "imageUrl":
          "https://images.unsplash.com/photo-1611224923853-80b023f02d71?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8c29jaWFsJTIwbWVkaWF8ZW58MHx8MHx8fDA%3D",
      "title": "สร้างเนื้อหาด้วย AI",
      "description":
          "ใช้ปัญญาประดิษฐ์ในการสร้างเนื้อหาโซเชียลมีเดียที่น่าสนใจและเหมาะสมกับแบรนด์ของคุณ พร้อมคำแนะนำที่ชาญฉลาด",
    },
    {
      "imageUrl":
          "https://images.unsplash.com/photo-1551288049-bebda4e38f71?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8c2NoZWR1bGV8ZW58MHx8MHx8fDA%3D",
      "title": "จัดตารางโพสต์อัตโนมัติ",
      "description":
          "วางแผนและจัดตารางการโพสต์ล่วงหน้าในหลายแพลตฟอร์ม ประหยัดเวลาและรักษาความสม่ำเสมอของเนื้อหา",
    },
    {
      "imageUrl":
          "https://images.unsplash.com/photo-1551288049-bebda4e38f71?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8YW5hbHl0aWNzfGVufDB8fDB8fHww",
      "title": "วิเคราะห์ผลงานแบบละเอียด",
      "description":
          "ติดตามและวิเคราะห์ประสิทธิภาพของเนื้อหา พร้อมข้อมูลเชิงลึกที่จะช่วยปรับปรุงกลยุทธ์การตลาดของคุณ",
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _triggerHapticFeedback();
    }
  }

  void _skipOnboarding() {
    _navigateToLogin();
  }

  void _getStarted() {
    _navigateToLogin();
  }

  void _jumpToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _triggerHapticFeedback();
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login-screen');
  }

  void _triggerHapticFeedback() {
    HapticFeedback.lightImpact();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getSurfaceColor(context),
      body: Column(
        children: [
          // Progress indicator at top
          SizedBox(height: 6.h),
          ProgressIndicatorWidget(
            currentStep: _currentPage,
            totalSteps: _totalPages,
          ),

          // Main content area with PageView
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _totalPages,
              itemBuilder: (context, index) {
                final data = _onboardingData[index];
                return OnboardingPageWidget(
                  imageUrl: data["imageUrl"] as String,
                  title: data["title"] as String,
                  description: data["description"] as String,
                );
              },
            ),
          ),

          // Page control dots
          Container(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            child: PageControlDotsWidget(
              currentPage: _currentPage,
              totalPages: _totalPages,
              onDotTapped: _jumpToPage,
            ),
          ),

          // Bottom navigation
          BottomNavigationWidget(
            currentPage: _currentPage,
            totalPages: _totalPages,
            onNext: _nextPage,
            onSkip: _skipOnboarding,
            onGetStarted: _getStarted,
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}
