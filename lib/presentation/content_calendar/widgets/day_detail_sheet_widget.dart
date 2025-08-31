import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './post_item_widget.dart';

class DayDetailSheetWidget extends StatelessWidget {
  final DateTime selectedDate;
  final List<Map<String, dynamic>> posts;
  final Function(Map<String, dynamic>) onPostTap;
  final Function(Map<String, dynamic>) onPostEdit;
  final Function(Map<String, dynamic>) onPostDelete;
  final VoidCallback onCreatePost;

  const DayDetailSheetWidget({
    Key? key,
    required this.selectedDate,
    required this.posts,
    required this.onPostTap,
    required this.onPostEdit,
    required this.onPostDelete,
    required this.onCreatePost,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sortedPosts = List<Map<String, dynamic>>.from(posts)
      ..sort((a, b) {
        final timeA = DateTime.parse(a['scheduledDate'] as String);
        final timeB = DateTime.parse(b['scheduledDate'] as String);
        return timeA.compareTo(timeB);
      });

    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.symmetric(vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.getBorderColor(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
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
                        '${posts.length} โพสต์',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color:
                              AppTheme.getTextColor(context, secondary: true),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onCreatePost,
                  icon: CustomIconWidget(
                    iconName: 'add',
                    size: 24,
                    color: AppTheme.lightTheme.primaryColor,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(
            color: AppTheme.getBorderColor(context),
            thickness: 1,
            height: 1,
          ),

          // Posts list
          Expanded(
            child: posts.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    itemCount: sortedPosts.length,
                    itemBuilder: (context, index) {
                      final post = sortedPosts[index];
                      return PostItemWidget(
                        post: post,
                        onTap: () => onPostTap(post),
                        onLongPress: () => _showPostOptions(context, post),
                      );
                    },
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
          CustomIconWidget(
            iconName: 'event_note',
            size: 64,
            color: AppTheme.borderLight.withValues(alpha: 0.5),
          ),
          SizedBox(height: 2.h),
          Text(
            'ไม่มีโพสต์ในวันนี้',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'แตะปุ่ม + เพื่อสร้างโพสต์ใหม่',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
          ),
          SizedBox(height: 3.h),
          ElevatedButton.icon(
            onPressed: onCreatePost,
            icon: CustomIconWidget(
              iconName: 'add',
              size: 20,
              color: Colors.white,
            ),
            label: Text('สร้างโพสต์'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
            ),
          ),
        ],
      ),
    );
  }

  void _showPostOptions(BuildContext context, Map<String, dynamic> post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
            ListTile(
              leading: CustomIconWidget(
                iconName: 'visibility',
                size: 24,
                color: AppTheme.getTextColor(context),
              ),
              title: Text('ดูรายละเอียด'),
              onTap: () {
                Navigator.pop(context);
                onPostTap(post);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'edit',
                size: 24,
                color: AppTheme.lightTheme.primaryColor,
              ),
              title: Text('แก้ไข'),
              onTap: () {
                Navigator.pop(context);
                onPostEdit(post);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'schedule',
                size: 24,
                color: Color(0xFFD97706),
              ),
              title: Text('เปลี่ยนเวลา'),
              onTap: () {
                Navigator.pop(context);
                // Handle reschedule
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                size: 24,
                color: Color(0xFFDC2626),
              ),
              title: Text('ลบ'),
              onTap: () {
                Navigator.pop(context);
                onPostDelete(post);
              },
            ),
            SizedBox(height: 2.h),
          ],
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

    final weekdays = [
      'จันทร์',
      'อังคาร',
      'พุธ',
      'พฤหัสบดี',
      'ศุกร์',
      'เสาร์',
      'อาทิตย์'
    ];

    return '${weekdays[selectedDate.weekday - 1]} ${selectedDate.day} ${months[selectedDate.month - 1]} ${selectedDate.year + 543}';
  }
}