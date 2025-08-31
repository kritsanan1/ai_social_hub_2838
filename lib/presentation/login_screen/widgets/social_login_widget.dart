import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SocialLoginWidget extends StatelessWidget {
  final Function(String provider) onSocialLogin;
  final bool isLoading;

  const SocialLoginWidget({
    Key? key,
    required this.onSocialLogin,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider with text
        Row(
          children: [
            Expanded(
              child: Divider(
                color: AppTheme.getBorderColor(context),
                thickness: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'หรือเข้าสู่ระบบด้วย',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.getTextColor(context, secondary: true),
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: AppTheme.getBorderColor(context),
                thickness: 1,
              ),
            ),
          ],
        ),
        SizedBox(height: 3.h),

        // Social Login Buttons
        Column(
          children: [
            // Google Login Button
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: SignInButton(
                Buttons.Google,
                text: "เข้าสู่ระบบด้วย Google",
                onPressed: isLoading ? null : () => onSocialLogin('google'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 2.h),

            // Facebook Login Button
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: SignInButton(
                Buttons.Facebook,
                text: "เข้าสู่ระบบด้วย Facebook",
                onPressed: isLoading ? null : () => onSocialLogin('facebook'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 2.h),

            // Twitter Login Button
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: SignInButton(
                Buttons.Twitter,
                text: "เข้าสู่ระบบด้วย Twitter",
                onPressed: isLoading ? null : () => onSocialLogin('twitter'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
