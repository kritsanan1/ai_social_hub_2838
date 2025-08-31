import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AiSuggestionsWidget extends StatefulWidget {
  final Function(String) onSuggestionTap;
  final VoidCallback onRegenerate;

  const AiSuggestionsWidget({
    Key? key,
    required this.onSuggestionTap,
    required this.onRegenerate,
  }) : super(key: key);

  @override
  State<AiSuggestionsWidget> createState() => _AiSuggestionsWidgetState();
}

class _AiSuggestionsWidgetState extends State<AiSuggestionsWidget> {
  final List<Map<String, dynamic>> aiSuggestions = [
    {
      "id": 1,
      "text":
          "🚀 เปิดตัวฟีเจอร์ใหม่ที่จะเปลี่ยนวิธีการทำงานของคุณ! มาดูกันว่าเราได้พัฒนาอะไรมาให้",
      "category": "product_launch",
      "engagement_score": 8.5
    },
    {
      "id": 2,
      "text":
          "💡 เคล็ดลับการเพิ่มประสิทธิภาพในการทำงาน: 5 วิธีง่ายๆ ที่จะทำให้คุณประสบความสำเร็จมากขึ้น",
      "category": "tips",
      "engagement_score": 7.8
    },
    {
      "id": 3,
      "text":
          "🌟 ขอบคุณลูกค้าทุกท่านที่ไว้วางใจในบริการของเรา! เรื่องราวความสำเร็จของคุณคือแรงบันดาลใจของเรา",
      "category": "gratitude",
      "engagement_score": 9.2
    },
    {
      "id": 4,
      "text":
          "📊 สถิติที่น่าสนใจ: 85% ของผู้ใช้งานรายงานว่าประสิทธิภาพเพิ่มขึ้นหลังจากใช้บริการของเรา",
      "category": "statistics",
      "engagement_score": 6.9
    },
  ];

  bool isLoading = false;

  Future<void> _regenerateSuggestions() async {
    setState(() {
      isLoading = true;
    });

    // Simulate AI regeneration
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isLoading = false;
    });

    widget.onRegenerate();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AI Content Suggestions',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextColor(context),
                ),
              ),
              GestureDetector(
                onTap: isLoading ? null : _regenerateSuggestions,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color:
                        AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isLoading)
                        SizedBox(
                          width: 4.w,
                          height: 4.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.lightTheme.primaryColor,
                            ),
                          ),
                        )
                      else
                        CustomIconWidget(
                          iconName: 'refresh',
                          size: 4.w,
                          color: AppTheme.lightTheme.primaryColor,
                        ),
                      SizedBox(width: 2.w),
                      Text(
                        'Regenerate',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          SizedBox(
            height: 12.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: aiSuggestions.length,
              separatorBuilder: (context, index) => SizedBox(width: 3.w),
              itemBuilder: (context, index) {
                final suggestion = aiSuggestions[index];
                return GestureDetector(
                  onTap: () =>
                      widget.onSuggestionTap(suggestion["text"] as String),
                  child: Container(
                    width: 75.w,
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.getSurfaceColor(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.getBorderColor(context),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 0.5.h),
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.primaryColor
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                (suggestion["category"] as String)
                                    .replaceAll('_', ' ')
                                    .toUpperCase(),
                                style: AppTheme.lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                  color: AppTheme.lightTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'trending_up',
                                  size: 3.w,
                                  color: AppTheme.successLight,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  '${suggestion["engagement_score"]}',
                                  style: AppTheme
                                      .lightTheme.textTheme.labelSmall
                                      ?.copyWith(
                                    color: AppTheme.successLight,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        Expanded(
                          child: Text(
                            suggestion["text"] as String,
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.getTextColor(context),
                              height: 1.3,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 1.h),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.primaryColor
                                .withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: 'add',
                                size: 4.w,
                                color: AppTheme.lightTheme.primaryColor,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Tap to Insert',
                                style: AppTheme.lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                  color: AppTheme.lightTheme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
