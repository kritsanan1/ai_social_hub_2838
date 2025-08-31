import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SchedulingWidget extends StatefulWidget {
  final bool isScheduled;
  final DateTime? scheduledDateTime;
  final Function(bool, DateTime?) onSchedulingChanged;

  const SchedulingWidget({
    Key? key,
    required this.isScheduled,
    this.scheduledDateTime,
    required this.onSchedulingChanged,
  }) : super(key: key);

  @override
  State<SchedulingWidget> createState() => _SchedulingWidgetState();
}

class _SchedulingWidgetState extends State<SchedulingWidget> {
  late bool _isScheduled;
  DateTime? _selectedDateTime;

  final List<Map<String, dynamic>> optimalTimes = [
    {
      "platform": "Instagram",
      "time": "18:00",
      "day": "Tuesday",
      "engagement": "High",
      "color": Color(0xFFE4405F)
    },
    {
      "platform": "Facebook",
      "time": "15:00",
      "day": "Wednesday",
      "engagement": "Medium",
      "color": Color(0xFF1877F2)
    },
    {
      "platform": "Twitter",
      "time": "12:00",
      "day": "Monday",
      "engagement": "High",
      "color": Color(0xFF1DA1F2)
    },
  ];

  @override
  void initState() {
    super.initState();
    _isScheduled = widget.isScheduled;
    _selectedDateTime = widget.scheduledDateTime;
  }

  Future<void> _selectDateTime() async {
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.lightTheme.primaryColor,
                ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          _selectedDateTime ?? now.add(const Duration(hours: 1)),
        ),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: AppTheme.lightTheme.primaryColor,
                  ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        final DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          _selectedDateTime = selectedDateTime;
        });

        widget.onSchedulingChanged(_isScheduled, _selectedDateTime);
      }
    }
  }

  void _toggleScheduling(bool value) {
    setState(() {
      _isScheduled = value;
      if (!value) {
        _selectedDateTime = null;
      } else if (_selectedDateTime == null) {
        _selectedDateTime = DateTime.now().add(const Duration(hours: 1));
      }
    });

    widget.onSchedulingChanged(_isScheduled, _selectedDateTime);
  }

  void _useOptimalTime(Map<String, dynamic> optimalTime) {
    final DateTime now = DateTime.now();
    final DateTime nextWeek = now.add(const Duration(days: 7));

    // Find the next occurrence of the optimal day
    int targetWeekday = _getWeekdayFromString(optimalTime["day"] as String);
    int daysUntilTarget = (targetWeekday - now.weekday) % 7;
    if (daysUntilTarget == 0 &&
        now.hour >= int.parse((optimalTime["time"] as String).split(':')[0])) {
      daysUntilTarget =
          7; // If today but time has passed, schedule for next week
    }

    final DateTime targetDate = now.add(Duration(days: daysUntilTarget));
    final List<String> timeParts = (optimalTime["time"] as String).split(':');
    final DateTime optimalDateTime = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );

    setState(() {
      _isScheduled = true;
      _selectedDateTime = optimalDateTime;
    });

    widget.onSchedulingChanged(_isScheduled, _selectedDateTime);
  }

  int _getWeekdayFromString(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return 1;
      case 'tuesday':
        return 2;
      case 'wednesday':
        return 3;
      case 'thursday':
        return 4;
      case 'friday':
        return 5;
      case 'saturday':
        return 6;
      case 'sunday':
        return 7;
      default:
        return 1;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    final String day = dateTime.day.toString().padLeft(2, '0');
    final String month = months[dateTime.month - 1];
    final String year = dateTime.year.toString();
    final String hour = dateTime.hour.toString().padLeft(2, '0');
    final String minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day $month $year at $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scheduling Options',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextColor(context),
            ),
          ),
          SizedBox(height: 2.h),

          // Post Now / Schedule Toggle
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.getSurfaceColor(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.getBorderColor(context),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _toggleScheduling(false),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      decoration: BoxDecoration(
                        color: !_isScheduled
                            ? AppTheme.lightTheme.primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'send',
                            size: 5.w,
                            color: !_isScheduled
                                ? Colors.white
                                : AppTheme.getTextColor(context,
                                    secondary: true),
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Post Now',
                            style: AppTheme.lightTheme.textTheme.titleSmall
                                ?.copyWith(
                              color: !_isScheduled
                                  ? Colors.white
                                  : AppTheme.getTextColor(context,
                                      secondary: true),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _toggleScheduling(true),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      decoration: BoxDecoration(
                        color: _isScheduled
                            ? AppTheme.lightTheme.primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'schedule',
                            size: 5.w,
                            color: _isScheduled
                                ? Colors.white
                                : AppTheme.getTextColor(context,
                                    secondary: true),
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Schedule',
                            style: AppTheme.lightTheme.textTheme.titleSmall
                                ?.copyWith(
                              color: _isScheduled
                                  ? Colors.white
                                  : AppTheme.getTextColor(context,
                                      secondary: true),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_isScheduled) ...[
            SizedBox(height: 2.h),

            // Date Time Picker
            GestureDetector(
              onTap: _selectDateTime,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.getSurfaceColor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.getBorderColor(context),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.primaryColor
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: 'calendar_today',
                        size: 6.w,
                        color: AppTheme.lightTheme.primaryColor,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scheduled Date & Time',
                            style: AppTheme.lightTheme.textTheme.labelMedium
                                ?.copyWith(
                              color: AppTheme.getTextColor(context,
                                  secondary: true),
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            _selectedDateTime != null
                                ? _formatDateTime(_selectedDateTime!)
                                : 'Tap to select date and time',
                            style: AppTheme.lightTheme.textTheme.titleSmall
                                ?.copyWith(
                              color: AppTheme.getTextColor(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CustomIconWidget(
                      iconName: 'arrow_forward_ios',
                      size: 4.w,
                      color: AppTheme.getTextColor(context, secondary: true),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 2.h),

            // Optimal Times Section
            Text(
              'AI Recommended Times',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextColor(context),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Based on your audience engagement patterns',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.getTextColor(context, secondary: true),
              ),
            ),
            SizedBox(height: 1.5.h),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: optimalTimes.length,
              separatorBuilder: (context, index) => SizedBox(height: 1.h),
              itemBuilder: (context, index) {
                final optimalTime = optimalTimes[index];
                return GestureDetector(
                  onTap: () => _useOptimalTime(optimalTime),
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.getSurfaceColor(context),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.getBorderColor(context),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 3.w,
                          height: 6.h,
                          decoration: BoxDecoration(
                            color: optimalTime["color"] as Color,
                            borderRadius: BorderRadius.circular(2),
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
                                    optimalTime["platform"] as String,
                                    style: AppTheme
                                        .lightTheme.textTheme.titleSmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.getTextColor(context),
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 2.w, vertical: 0.5.h),
                                    decoration: BoxDecoration(
                                      color: (optimalTime["engagement"]
                                                  as String) ==
                                              "High"
                                          ? AppTheme.successLight
                                              .withValues(alpha: 0.1)
                                          : AppTheme.warningLight
                                              .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${optimalTime["engagement"]} Engagement',
                                      style: AppTheme
                                          .lightTheme.textTheme.labelSmall
                                          ?.copyWith(
                                        color: (optimalTime["engagement"]
                                                    as String) ==
                                                "High"
                                            ? AppTheme.successLight
                                            : AppTheme.warningLight,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                '${optimalTime["day"]} at ${optimalTime["time"]}',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme.getTextColor(context,
                                      secondary: true),
                                ),
                              ),
                            ],
                          ),
                        ),
                        CustomIconWidget(
                          iconName: 'arrow_forward_ios',
                          size: 4.w,
                          color:
                              AppTheme.getTextColor(context, secondary: true),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
