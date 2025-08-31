import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './post_item_widget.dart';

class DayViewWidget extends StatelessWidget {
  final DateTime selectedDay;
  final List<Map<String, dynamic>> scheduledPosts;
  final Function(Map<String, dynamic>) onPostTap;
  final Function(Map<String, dynamic>) onPostLongPress;

  const DayViewWidget({
    Key? key,
    required this.selectedDay,
    required this.scheduledPosts,
    required this.onPostTap,
    required this.onPostLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dayPosts = _getPostsForDay();
    final sortedPosts = List<Map<String, dynamic>>.from(dayPosts)
      ..sort((a, b) {
        final timeA = DateTime.parse(a['scheduledDate'] as String);
        final timeB = DateTime.parse(b['scheduledDate'] as String);
        return timeA.compareTo(timeB);
      });

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Day header
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getFormattedDate(),
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          color: AppTheme.getTextColor(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${sortedPosts.length} โพสต์ที่กำหนดไว้',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color:
                              AppTheme.getTextColor(context, secondary: true),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isToday()) ...[
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'วันนี้',
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Timeline
          Expanded(
            child: sortedPosts.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    itemCount: 24,
                    itemBuilder: (context, hour) {
                      final hourPosts = _getPostsForHour(sortedPosts, hour);
                      return _buildHourSlot(context, hour, hourPosts);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourSlot(
      BuildContext context, int hour, List<Map<String, dynamic>> hourPosts) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time label
          Container(
            width: 20.w,
            padding: EdgeInsets.only(top: 1.h, right: 2.w),
            child: Text(
              '${hour.toString().padLeft(2, '0')}:00',
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.getTextColor(context, secondary: true),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),

          // Timeline line
          Container(
            width: 2,
            height: hourPosts.isEmpty ? 6.h : null,
            margin: EdgeInsets.symmetric(horizontal: 2.w),
            decoration: BoxDecoration(
              color: hourPosts.isEmpty
                  ? AppTheme.getBorderColor(context).withValues(alpha: 0.3)
                  : AppTheme.lightTheme.primaryColor,
              borderRadius: BorderRadius.circular(1),
            ),
            child: hourPosts.isNotEmpty
                ? Column(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: 2,
                          color: AppTheme.lightTheme.primaryColor
                              .withValues(alpha: 0.3),
                        ),
                      ),
                    ],
                  )
                : null,
          ),

          // Posts
          Expanded(
            child: hourPosts.isEmpty
                ? SizedBox(height: 6.h)
                : Column(
                    children: hourPosts.map((post) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 1.h),
                        child: PostItemWidget(
                          post: post,
                          onTap: () => onPostTap(post),
                          onLongPress: () => onPostLongPress(post),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Builder(
            builder: (context) => CustomIconWidget(
              iconName: 'schedule',
              size: 64,
              color: AppTheme.getBorderColor(context).withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: 2.h),
          Builder(
            builder: (context) => Text(
              'ไม่มีโพสต์ในวันนี้',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.getTextColor(context, secondary: true),
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Builder(
            builder: (context) => Text(
              'วันนี้ยังไม่มีโพสต์ที่กำหนดไว้',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.getTextColor(context, secondary: true),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getPostsForDay() {
    return scheduledPosts.where((post) {
      final postDate = DateTime.parse(post['scheduledDate'] as String);
      return postDate.day == selectedDay.day &&
          postDate.month == selectedDay.month &&
          postDate.year == selectedDay.year;
    }).toList();
  }

  List<Map<String, dynamic>> _getPostsForHour(
      List<Map<String, dynamic>> posts, int hour) {
    return posts.where((post) {
      final postDate = DateTime.parse(post['scheduledDate'] as String);
      return postDate.hour == hour;
    }).toList();
  }

  bool _isToday() {
    final now = DateTime.now();
    return selectedDay.day == now.day &&
        selectedDay.month == now.month &&
        selectedDay.year == now.year;
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

    final weekdays = [
      'จันทร์',
      'อังคาร',
      'พุธ',
      'พฤหัสบดี',
      'ศุกร์',
      'เสาร์',
      'อาทิตย์'
    ];

    return '${weekdays[selectedDay.weekday - 1]} ${selectedDay.day} ${months[selectedDay.month - 1]} ${selectedDay.year + 543}';
  }
}