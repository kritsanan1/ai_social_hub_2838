import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PostItemWidget extends StatelessWidget {
  final Map<String, dynamic> post;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool isSelected;

  const PostItemWidget({
    Key? key,
    required this.post,
    required this.onTap,
    required this.onLongPress,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scheduledTime = DateTime.parse(post['scheduledDate'] as String);
    final platforms = (post['platforms'] as List).cast<String>();

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 2.w),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1)
              : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.lightTheme.primaryColor
                : AppTheme.getBorderColor(context),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getStatusText(),
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Spacer(),
                Text(
                  '${scheduledTime.hour.toString().padLeft(2, '0')}:${scheduledTime.minute.toString().padLeft(2, '0')}',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.getTextColor(context, secondary: true),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              post['content'] as String,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.getTextColor(context),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (post['imageUrl'] != null) ...[
              SizedBox(height: 1.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomImageWidget(
                  imageUrl: post['imageUrl'] as String,
                  width: double.infinity,
                  height: 15.h,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            SizedBox(height: 1.h),
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 1.w,
                    children: platforms.map((platform) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: _getPlatformColor(platform)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: _getPlatformIcon(platform),
                              size: 12,
                              color: _getPlatformColor(platform),
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              platform,
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                color: _getPlatformColor(platform),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                CustomIconWidget(
                  iconName: 'more_vert',
                  size: 20,
                  color: AppTheme.getTextColor(context, secondary: true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    final status = post['status'] as String;
    switch (status.toLowerCase()) {
      case 'scheduled':
        return AppTheme.lightTheme.primaryColor;
      case 'published':
        return Color(0xFF059669);
      case 'draft':
        return Color(0xFFD97706);
      case 'failed':
        return Color(0xFFDC2626);
      default:
        return AppTheme.lightTheme.colorScheme.secondary;
    }
  }

  String _getStatusText() {
    final status = post['status'] as String;
    switch (status.toLowerCase()) {
      case 'scheduled':
        return 'กำหนดเผยแพร่';
      case 'published':
        return 'เผยแพร่แล้ว';
      case 'draft':
        return 'แบบร่าง';
      case 'failed':
        return 'ล้มเหลว';
      default:
        return status;
    }
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
        return Color(0xFF0A66C2);
      case 'tiktok':
        return Color(0xFF000000);
      case 'youtube':
        return Color(0xFFFF0000);
      default:
        return AppTheme.lightTheme.colorScheme.secondary;
    }
  }

  String _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return 'facebook';
      case 'instagram':
        return 'camera_alt';
      case 'twitter':
        return 'alternate_email';
      case 'linkedin':
        return 'business';
      case 'tiktok':
        return 'music_note';
      case 'youtube':
        return 'play_circle_filled';
      default:
        return 'share';
    }
  }
}
