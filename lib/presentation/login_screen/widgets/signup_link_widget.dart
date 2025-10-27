import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SignupLinkWidget extends StatelessWidget {
  final VoidCallback onSignupTap;
  final bool isSignup;

  const SignupLinkWidget({
    Key? key,
    required this.onSignupTap,
    this.isSignup = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isSignup ? 'มีบัญชีอยู่แล้ว? ' : 'ยังไม่มีบัญชี? ',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.getTextColor(context, secondary: true),
            ),
          ),
          GestureDetector(
            onTap: onSignupTap,
            child: Text(
              isSignup ? 'เข้าสู่ระบบ' : 'สมัครสมาชิก',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
