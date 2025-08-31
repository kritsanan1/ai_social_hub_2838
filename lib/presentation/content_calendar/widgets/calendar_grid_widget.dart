import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class CalendarGridWidget extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;
  final List<Map<String, dynamic>> scheduledPosts;
  final Function(DateTime) onDayLongPress;

  const CalendarGridWidget({
    Key? key,
    required this.focusedDay,
    this.selectedDay,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.scheduledPosts,
    required this.onDayLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      child: TableCalendar<Map<String, dynamic>>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        eventLoader: _getEventsForDay,
        onDaySelected: onDaySelected,
        onPageChanged: onPageChanged,
        onDayLongPressed: (selectedDay, focusedDay) =>
            onDayLongPress(selectedDay),
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        headerVisible: false,
        daysOfWeekVisible: true,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.getTextColor(context),
          ) ?? TextStyle(color: AppTheme.getTextColor(context)),
          holidayTextStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.error,
          ) ?? TextStyle(color: AppTheme.lightTheme.colorScheme.error),
          defaultTextStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.getTextColor(context),
          ) ?? TextStyle(color: AppTheme.getTextColor(context)),
          selectedTextStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ) ?? TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          todayTextStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.primaryColor,
            fontWeight: FontWeight.w600,
          ) ?? TextStyle(color: AppTheme.lightTheme.primaryColor, fontWeight: FontWeight.w600),
          selectedDecoration: BoxDecoration(
            color: AppTheme.lightTheme.primaryColor,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.secondary,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 3,
          canMarkersOverflow: true,
          cellMargin: EdgeInsets.all(1.w),
          cellPadding: EdgeInsets.zero,
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color: AppTheme.getTextColor(context, secondary: true),
            fontWeight: FontWeight.w500,
          ) ?? TextStyle(color: AppTheme.getTextColor(context, secondary: true), fontWeight: FontWeight.w500),
          weekendStyle: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color: AppTheme.getTextColor(context, secondary: true),
            fontWeight: FontWeight.w500,
          ) ?? TextStyle(color: AppTheme.getTextColor(context, secondary: true), fontWeight: FontWeight.w500),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isEmpty) return null;

            return Positioned(
              bottom: 1,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: events.take(3).map((event) {
                  final eventData = event;
                  return Container(
                    width: 6,
                    height: 6,
                    margin: EdgeInsets.symmetric(horizontal: 0.5),
                    decoration: BoxDecoration(
                      color: _getPlatformColor(eventData['platform'] as String),
                      shape: BoxShape.circle,
                    ),
                  );
                }).toList(),
              ),
            );
          },
          defaultBuilder: (context, date, _) {
            final events = _getEventsForDay(date);
            return Container(
              margin: EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: events.isNotEmpty
                    ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.05)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${date.day}',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.getTextColor(context),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return scheduledPosts.where((post) {
      final postDate = DateTime.parse(post['scheduledDate'] as String);
      return isSameDay(postDate, day);
    }).toList();
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