import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SettingsSectionWidget extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final Function(String, dynamic)? onItemTap;

  const SettingsSectionWidget({
    Key? key,
    required this.title,
    required this.items,
    this.onItemTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Text(
              title,
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: AppTheme.getBorderColor(context),
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildSettingItem(context, item);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, Map<String, dynamic> item) {
    final String type = item["type"] as String;

    return InkWell(
      onTap: type == "navigation"
          ? () => onItemTap?.call(item["key"] as String, null)
          : null,
      child: Container(
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: (item["iconColor"] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: item["icon"] as String,
                color: item["iconColor"] as Color,
                size: 5.w,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item["title"] as String,
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (item["subtitle"] != null) ...[
                    SizedBox(height: 0.5.h),
                    Text(
                      item["subtitle"] as String,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.getTextColor(context, secondary: true),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            _buildTrailingWidget(context, item),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailingWidget(BuildContext context, Map<String, dynamic> item) {
    final String type = item["type"] as String;

    switch (type) {
      case "switch":
        return Switch(
          value: item["value"] as bool,
          onChanged: (value) => onItemTap?.call(item["key"] as String, value),
        );
      case "navigation":
        return CustomIconWidget(
          iconName: 'chevron_right',
          color: AppTheme.getTextColor(context, secondary: true),
          size: 5.w,
        );
      case "badge":
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: item["badgeColor"] as Color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            item["badgeText"] as String,
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
