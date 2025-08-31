import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MessageFilterWidget extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const MessageFilterWidget({
    Key? key,
    required this.selectedFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'value': 'all', 'label': 'ทั้งหมด', 'icon': 'all_inclusive'},
      {'value': 'unread', 'label': 'ยังไม่อ่าน', 'icon': 'mark_email_unread'},
      {'value': 'priority', 'label': 'สำคัญ', 'icon': 'priority_high'},
      {'value': 'online', 'label': 'ออนไลน์', 'icon': 'online_prediction'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.symmetric(vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.getBorderColor(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              children: [
                Text(
                  'กรองข้อความ',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                if (selectedFilter != 'all')
                  TextButton(
                    onPressed: () => onFilterChanged('all'),
                    child: Text('รีเซ็ต'),
                  ),
              ],
            ),
          ),
          ...filters.map((filter) => ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: selectedFilter == filter['value']
                        ? AppTheme.lightTheme.primaryColor
                            .withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selectedFilter == filter['value']
                          ? AppTheme.lightTheme.primaryColor
                          : AppTheme.getBorderColor(context),
                      width: 1,
                    ),
                  ),
                  child: CustomIconWidget(
                    iconName: filter['icon'] as String,
                    color: selectedFilter == filter['value']
                        ? AppTheme.lightTheme.primaryColor
                        : AppTheme.getTextColor(context, secondary: true),
                    size: 20,
                  ),
                ),
                title: Text(
                  filter['label'] as String,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: selectedFilter == filter['value']
                        ? AppTheme.lightTheme.primaryColor
                        : AppTheme.getTextColor(context),
                    fontWeight: selectedFilter == filter['value']
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
                trailing: selectedFilter == filter['value']
                    ? CustomIconWidget(
                        iconName: 'check',
                        color: AppTheme.lightTheme.primaryColor,
                        size: 20,
                      )
                    : null,
                onTap: () => onFilterChanged(filter['value'] as String),
              )),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}
