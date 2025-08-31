import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PlatformTabsWidget extends StatelessWidget {
  final List<String> platforms;
  final TabController controller;
  final Function(int) onTabChanged;

  const PlatformTabsWidget({
    Key? key,
    required this.platforms,
    required this.controller,
    required this.onTabChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.getBorderColor(context),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: controller,
        isScrollable: true,
        indicatorColor: AppTheme.lightTheme.primaryColor,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppTheme.lightTheme.primaryColor,
        unselectedLabelColor: AppTheme.getTextColor(context, secondary: true),
        labelStyle: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle:
            AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w400,
        ),
        onTap: onTabChanged,
        tabs: platforms
            .map((platform) => Tab(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (platform != 'All') ...[
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: _getPlatformColor(platform).withValues(
                                  alpha: controller.index ==
                                          platforms.indexOf(platform)
                                      ? 1.0
                                      : 0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: CustomIconWidget(
                              iconName: platform.toLowerCase(),
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                          SizedBox(width: 2.w),
                        ],
                        Text(
                          platform == 'All' ? 'ทั้งหมด' : platform,
                        ),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return Color(0xFF1877F2);
      case 'instagram':
        return Color(0xFFE4405F);
      case 'twitter':
        return Color(0xFF1DA1F2);
      case 'linkedin':
        return Color(0xFF0077B5);
      default:
        return AppTheme.lightTheme.primaryColor;
    }
  }
}
