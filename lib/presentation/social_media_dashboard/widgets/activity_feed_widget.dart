import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ActivityFeedWidget extends StatelessWidget {
  final List<Map<String, dynamic>> activities;
  final Function(Map<String, dynamic>) onActivityTap;
  final Function(Map<String, dynamic>) onReply;
  final Function(Map<String, dynamic>) onLike;
  final Function(Map<String, dynamic>) onShare;

  const ActivityFeedWidget({
    Key? key,
    required this.activities,
    required this.onActivityTap,
    required this.onReply,
    required this.onLike,
    required this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'กิจกรรมล่าสุด',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextColor(context),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to full activity feed
                },
                child: Text('ดูทั้งหมด'),
              ),
            ],
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
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
          child: ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: activities.take(5).length,
            separatorBuilder: (context, index) => Divider(
              color: AppTheme.getBorderColor(context),
              height: 1,
            ),
            itemBuilder: (context, index) {
              final activity = activities[index];
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onActivityTap(activity),
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _getPlatformColor(
                                activity['platform'] as String),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CustomIconWidget(
                            iconName:
                                _getActivityIcon(activity['type'] as String),
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    activity['platform'] as String,
                                    style: AppTheme
                                        .lightTheme.textTheme.labelMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: _getPlatformColor(
                                          activity['platform'] as String),
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    _formatActivityTime(
                                        activity['timestamp'] as DateTime),
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: AppTheme.getTextColor(context,
                                          secondary: true),
                                    ),
                                  ),
                                  if (activity['requiresAttention'] ==
                                      true) ...[
                                    SizedBox(width: 2.w),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFDC2626),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                activity['content'] as String,
                                style: AppTheme.lightTheme.textTheme.bodyMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (activity['engagementCount'] != null &&
                                  activity['engagementCount'] > 0)
                                Padding(
                                  padding: EdgeInsets.only(top: 0.5.h),
                                  child: Text(
                                    '${activity['engagementCount']} การมีส่วนร่วม',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: AppTheme.getTextColor(context,
                                          secondary: true),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (activity['requiresAttention'] == true) ...[
                          Column(
                            children: [
                              IconButton(
                                onPressed: () => onReply(activity),
                                icon: CustomIconWidget(
                                  iconName: 'reply',
                                  size: 20,
                                  color: AppTheme.lightTheme.primaryColor,
                                ),
                                constraints:
                                    BoxConstraints(minWidth: 32, minHeight: 32),
                                padding: EdgeInsets.zero,
                              ),
                              IconButton(
                                onPressed: () => onLike(activity),
                                icon: CustomIconWidget(
                                  iconName: 'favorite_border',
                                  size: 20,
                                  color: AppTheme.getTextColor(context,
                                      secondary: true),
                                ),
                                constraints:
                                    BoxConstraints(minWidth: 32, minHeight: 32),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
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
        return Color(0xFF6B7280);
    }
  }

  String _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'comment':
        return 'comment';
      case 'mention':
        return 'alternate_email';
      case 'message':
        return 'message';
      case 'like':
        return 'favorite';
      case 'share':
        return 'share';
      default:
        return 'notifications';
    }
  }

  String _formatActivityTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} นาทีที่แล้ว';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ชั่วโมงที่แล้ว';
    } else {
      return '${difference.inDays} วันที่แล้ว';
    }
  }
}
