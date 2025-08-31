import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const ProgressIndicatorWidget({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 0.8.h,
      margin: EdgeInsets.symmetric(horizontal: 6.w),
      child: Row(
        children: List.generate(totalSteps, (index) {
          return Expanded(
            child: Container(
              height: 0.8.h,
              margin: EdgeInsets.only(right: index < totalSteps - 1 ? 1.w : 0),
              decoration: BoxDecoration(
                color: index <= currentStep
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.getBorderColor(context),
                borderRadius: BorderRadius.circular(0.4.h),
              ),
            ),
          );
        }),
      ),
    );
  }
}
