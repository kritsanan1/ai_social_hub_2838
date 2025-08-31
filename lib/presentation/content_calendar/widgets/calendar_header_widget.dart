import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class CalendarHeaderWidget extends StatelessWidget {
  final String selectedView;
  final Function(String) onViewChanged;
  final VoidCallback onTodayPressed;
  final DateTime currentDate;

  const CalendarHeaderWidget({
    Key? key,
    required this.selectedView,
    required this.onViewChanged,
    required this.onTodayPressed,
    required this.currentDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.getBorderColor(context),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getFormattedDate(),
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.getTextColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: onTodayPressed,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  backgroundColor:
                      AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'วันนี้',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.getBorderColor(context).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _buildViewButton('เดือน', 'Month'),
                _buildViewButton('สัปดาห์', 'Week'),
                _buildViewButton('วัน', 'Day'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewButton(String title, String value) {
    final isSelected = selectedView == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onViewChanged(value),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.lightTheme.primaryColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              color: isSelected
                  ? Colors.white
                  : AppTheme.textSecondaryLight,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  String _getFormattedDate() {
    final months = [
      'มกราคม',
      'กุมภาพันธ์',
      'มีนาคม',
      'เมษายน',
      'พฤษภาคม',
      'มิถุนายน',
      'กรกฎาคม',
      'สิงหาคม',
      'กันยายน',
      'ตุลาคม',
      'พฤศจิกายน',
      'ธันวาคม'
    ];

    switch (selectedView) {
      case 'Month':
        return '${months[currentDate.month - 1]} ${currentDate.year + 543}';
      case 'Week':
        final startOfWeek =
            currentDate.subtract(Duration(days: currentDate.weekday - 1));
        final endOfWeek = startOfWeek.add(Duration(days: 6));
        return '${startOfWeek.day}-${endOfWeek.day} ${months[currentDate.month - 1]} ${currentDate.year + 543}';
      case 'Day':
        return '${currentDate.day} ${months[currentDate.month - 1]} ${currentDate.year + 543}';
      default:
        return '${months[currentDate.month - 1]} ${currentDate.year + 543}';
    }
  }
}