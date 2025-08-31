import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ScheduledContentWidget extends StatelessWidget {
  final int scheduledCount;
  final VoidCallback onViewSchedule;
  final VoidCallback onCreatePost;

  const ScheduledContentWidget({
    Key? key,
    required this.scheduledCount,
    required this.onViewSchedule,
    required this.onCreatePost,
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
                'เนื้อหาที่กำหนดไว้',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextColor(context),
                ),
              ),
              TextButton(
                onPressed: onViewSchedule,
                child: Text('ดูปฏิทิน'),
              ),
            ],
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          padding: EdgeInsets.all(4.w),
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
          child: scheduledCount > 0
              ? Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.primaryColor
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CustomIconWidget(
                            iconName: 'schedule',
                            color: AppTheme.lightTheme.primaryColor,
                            size: 30,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$scheduledCount โพสต์ที่กำหนดไว้',
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                'พร้อมเผยแพร่ในสัปดาห์นี้',
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: AppTheme.getTextColor(context,
                                      secondary: true),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CustomIconWidget(
                            iconName: 'arrow_forward',
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    _buildUpcomingPosts(context),
                  ],
                )
              : _buildEmptyState(context),
        ),
      ],
    );
  }

  Widget _buildUpcomingPosts(BuildContext context) {
    // Mock data for upcoming posts
    final upcomingPosts = [
      {
        'title': 'AI Tips สำหรับการจัดการโซเชียลมีเดีย',
        'platform': 'Instagram',
        'time': 'วันนี้ 14:30',
        'thumbnail':
            'https://images.unsplash.com/photo-1677442136019-21780ecad995?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3',
      },
      {
        'title': 'Customer Success Story',
        'platform': 'Facebook',
        'time': 'พรุ่งนี้ 09:00',
        'thumbnail':
            'https://images.unsplash.com/photo-1460925895917-afdab827c52f?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'โพสต์ที่กำลังจะมา',
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color: AppTheme.getTextColor(context, secondary: true),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        ...upcomingPosts.map((post) => Container(
              margin: EdgeInsets.only(bottom: 2.h),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: CustomImageWidget(
                      imageUrl: post['thumbnail'] as String,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post['title'] as String,
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 0.5.h),
                              decoration: BoxDecoration(
                                color: _getPlatformColor(
                                        post['platform'] as String)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                post['platform'] as String,
                                style: AppTheme.lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                  color: _getPlatformColor(
                                      post['platform'] as String),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              post['time'] as String,
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.getTextColor(context,
                                    secondary: true),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.getBorderColor(context).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomIconWidget(
            iconName: 'schedule',
            color: AppTheme.getTextColor(context, secondary: true),
            size: 40,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          'ยังไม่มีเนื้อหาที่กำหนดไว้',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'เริ่มสร้างและกำหนดเวลาโพสต์เพื่อเพิ่มประสิทธิภาพ',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.getTextColor(context, secondary: true),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 3.h),
        ElevatedButton(
          onPressed: onCreatePost,
          child: Text('สร้างโพสต์แรก'),
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
        return AppTheme.lightTheme.primaryColor;
    }
  }
}
