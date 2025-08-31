import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class PageControlDotsWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onDotTapped;

  const PageControlDotsWidget({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.onDotTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        return GestureDetector(
          onTap: () => onDotTapped(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(horizontal: 1.w),
            width: index == currentPage ? 4.w : 2.w,
            height: 2.w,
            decoration: BoxDecoration(
              color: index == currentPage
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.getBorderColor(context),
              borderRadius: BorderRadius.circular(1.w),
            ),
          ),
        );
      }),
    );
  }
}
