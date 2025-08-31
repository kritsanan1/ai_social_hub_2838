import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class WeekViewWidget extends StatelessWidget {
  final DateTime currentWeek;
  final DateTime? selectedDay;
  final Function(DateTime) onDaySelected;
  final List<Map<String, dynamic>> scheduledPosts;
  final Function(DateTime) onDayLongPress;

  const WeekViewWidget({
    Key? key,
    required this.currentWeek,
    this.selectedDay,
    required this.onDaySelected,
    required this.scheduledPosts,
    required this.onDayLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final startOfWeek =
        currentWeek.subtract(Duration(days: currentWeek.weekday - 1));
    final weekDays =
        List.generate(7, (index) => startOfWeek.add(Duration(days: index)));

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
          // Week header
          Container(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            child: Row(
              children: weekDays.map((day) {
                final isSelected = selectedDay != null &&
                    day.day == selectedDay!.day &&
                    day.month == selectedDay!.month &&
                    day.year == selectedDay!.year;
                final isToday = _isToday(day);
                final dayPosts = _getPostsForDay(day);

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onDaySelected(day),
                    onLongPress: () => onDayLongPress(day),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 0.5.w),
                      padding: EdgeInsets.symmetric(vertical: 1.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.lightTheme.primaryColor
                            : isToday
                                ? AppTheme.lightTheme.primaryColor
                                    .withValues(alpha: 0.1)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _getWeekdayName(day.weekday),
                            style: AppTheme.lightTheme.textTheme.labelSmall
                                ?.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.getTextColor(context,
                                      secondary: true),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            '${day.day}',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : isToday
                                      ? AppTheme.lightTheme.primaryColor
                                      : AppTheme.getTextColor(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (dayPosts.isNotEmpty) ...[
                            SizedBox(height: 0.5.h),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.lightTheme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Time slots
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              itemCount: 24,
              itemBuilder: (context, hour) {
                return _buildHourSlot(context, hour, weekDays);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourSlot(
      BuildContext context, int hour, List<DateTime> weekDays) {
    return Container(
      height: 8.h,
      child: Row(
        children: [
          // Time label
          Container(
            width: 15.w,
            padding: EdgeInsets.only(right: 2.w),
            child: Text(
              '${hour.toString().padLeft(2, '0')}:00',
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: AppTheme.getTextColor(context, secondary: true),
              ),
              textAlign: TextAlign.right,
            ),
          ),

          // Day columns
          Expanded(
            child: Row(
              children: weekDays.map((day) {
                final hourPosts = _getPostsForDayAndHour(day, hour);

                return Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 0.5.w),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: AppTheme.getBorderColor(context)
                              .withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                        top: BorderSide(
                          color: AppTheme.getBorderColor(context)
                              .withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: hourPosts.isNotEmpty
                        ? Column(
                            children: hourPosts.take(2).map((post) {
                              return Expanded(
                                child: Container(
                                  width: double.infinity,
                                  margin: EdgeInsets.all(0.5.w),
                                  padding: EdgeInsets.all(1.w),
                                  decoration: BoxDecoration(
                                    color: _getPlatformColor(
                                            (post['platforms'] as List).first)
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: _getPlatformColor(
                                          (post['platforms'] as List).first),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    post['content'] as String,
                                    style: AppTheme
                                        .lightTheme.textTheme.labelSmall
                                        ?.copyWith(
                                      color: AppTheme.getTextColor(context),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        : SizedBox.expand(),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getPostsForDay(DateTime day) {
    return scheduledPosts.where((post) {
      final postDate = DateTime.parse(post['scheduledDate'] as String);
      return postDate.day == day.day &&
          postDate.month == day.month &&
          postDate.year == day.year;
    }).toList();
  }

  List<Map<String, dynamic>> _getPostsForDayAndHour(DateTime day, int hour) {
    return scheduledPosts.where((post) {
      final postDate = DateTime.parse(post['scheduledDate'] as String);
      return postDate.day == day.day &&
          postDate.month == day.month &&
          postDate.year == day.year &&
          postDate.hour == hour;
    }).toList();
  }

  bool _isToday(DateTime day) {
    final now = DateTime.now();
    return day.day == now.day && day.month == now.month && day.year == now.year;
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'];
    return weekdays[weekday - 1];
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
}
