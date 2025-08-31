import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PlatformSelectorWidget extends StatefulWidget {
  final List<String> selectedPlatforms;
  final Function(List<String>) onPlatformsChanged;
  final Function(String) onCharacterLimitChanged;

  const PlatformSelectorWidget({
    Key? key,
    required this.selectedPlatforms,
    required this.onPlatformsChanged,
    required this.onCharacterLimitChanged,
  }) : super(key: key);

  @override
  State<PlatformSelectorWidget> createState() => _PlatformSelectorWidgetState();
}

class _PlatformSelectorWidgetState extends State<PlatformSelectorWidget> {
  final List<Map<String, dynamic>> platforms = [
    {
      "id": "instagram",
      "name": "Instagram",
      "icon": "camera_alt",
      "color": Color(0xFFE4405F),
      "character_limit": 2200,
      "connected": true,
      "account": "@mybrand_official"
    },
    {
      "id": "facebook",
      "name": "Facebook",
      "icon": "facebook",
      "color": Color(0xFF1877F2),
      "character_limit": 63206,
      "connected": true,
      "account": "My Brand Page"
    },
    {
      "id": "twitter",
      "name": "Twitter",
      "icon": "alternate_email",
      "color": Color(0xFF1DA1F2),
      "character_limit": 280,
      "connected": true,
      "account": "@mybrand"
    },
    {
      "id": "linkedin",
      "name": "LinkedIn",
      "icon": "business",
      "color": Color(0xFF0A66C2),
      "character_limit": 3000,
      "connected": false,
      "account": "Not Connected"
    },
    {
      "id": "tiktok",
      "name": "TikTok",
      "icon": "music_note",
      "color": Color(0xFF000000),
      "character_limit": 2200,
      "connected": true,
      "account": "@mybrand_th"
    },
  ];

  void _togglePlatform(String platformId) {
    List<String> updatedPlatforms = List.from(widget.selectedPlatforms);

    if (updatedPlatforms.contains(platformId)) {
      updatedPlatforms.remove(platformId);
    } else {
      updatedPlatforms.add(platformId);
    }

    widget.onPlatformsChanged(updatedPlatforms);
    _updateCharacterLimit(updatedPlatforms);
  }

  void _updateCharacterLimit(List<String> selectedPlatforms) {
    if (selectedPlatforms.isEmpty) {
      widget.onCharacterLimitChanged("No platforms selected");
      return;
    }

    int minLimit = platforms
        .where((platform) => selectedPlatforms.contains(platform["id"]))
        .map((platform) => platform["character_limit"] as int)
        .reduce((a, b) => a < b ? a : b);

    String limitText = selectedPlatforms.length == 1
        ? "${platforms.firstWhere((p) => p["id"] == selectedPlatforms.first)["name"]}: $minLimit characters"
        : "Min limit: $minLimit characters";

    widget.onCharacterLimitChanged(limitText);
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
            'Select Platforms',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextColor(context),
            ),
          ),
          SizedBox(height: 1.5.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: platforms.length,
            separatorBuilder: (context, index) => SizedBox(height: 1.h),
            itemBuilder: (context, index) {
              final platform = platforms[index];
              final isSelected =
                  widget.selectedPlatforms.contains(platform["id"]);
              final isConnected = platform["connected"] as bool;

              return GestureDetector(
                onTap: isConnected
                    ? () => _togglePlatform(platform["id"] as String)
                    : null,
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (platform["color"] as Color).withValues(alpha: 0.1)
                        : AppTheme.getSurfaceColor(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? (platform["color"] as Color)
                          : AppTheme.getBorderColor(context),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: isConnected
                              ? (platform["color"] as Color)
                              : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: CustomIconWidget(
                            iconName: platform["icon"] as String,
                            size: 6.w,
                            color: Colors.white,
                          ),
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
                                  platform["name"] as String,
                                  style: AppTheme
                                      .lightTheme.textTheme.titleSmall
                                      ?.copyWith(
                                    color: AppTheme.getTextColor(context),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (isConnected) ...[
                                  SizedBox(width: 2.w),
                                  Container(
                                    width: 2.w,
                                    height: 2.w,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.successLight,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              isConnected
                                  ? platform["account"] as String
                                  : "Not Connected - Tap to Connect",
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: isConnected
                                    ? AppTheme.getTextColor(context,
                                        secondary: true)
                                    : AppTheme.warningLight,
                              ),
                            ),
                            if (isConnected) ...[
                              SizedBox(height: 0.5.h),
                              Text(
                                "Limit: ${platform["character_limit"]} characters",
                                style: AppTheme.lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                  color: AppTheme.getTextColor(context,
                                      secondary: true),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (isConnected)
                        Checkbox(
                          value: isSelected,
                          onChanged: (value) =>
                              _togglePlatform(platform["id"] as String),
                          activeColor: platform["color"] as Color,
                        )
                      else
                        CustomIconWidget(
                          iconName: 'link_off',
                          size: 5.w,
                          color: Colors.grey.shade400,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (widget.selectedPlatforms.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info',
                    size: 5.w,
                    color: AppTheme.lightTheme.primaryColor,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected: ${widget.selectedPlatforms.length} platform${widget.selectedPlatforms.length > 1 ? 's' : ''}',
                          style: AppTheme.lightTheme.textTheme.labelMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Content will be optimized for all selected platforms',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
