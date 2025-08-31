import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AdvancedOptionsWidget extends StatefulWidget {
  final List<String> selectedHashtags;
  final String? selectedLocation;
  final String selectedAudience;
  final Function(List<String>) onHashtagsChanged;
  final Function(String?) onLocationChanged;
  final Function(String) onAudienceChanged;

  const AdvancedOptionsWidget({
    Key? key,
    required this.selectedHashtags,
    this.selectedLocation,
    required this.selectedAudience,
    required this.onHashtagsChanged,
    required this.onLocationChanged,
    required this.onAudienceChanged,
  }) : super(key: key);

  @override
  State<AdvancedOptionsWidget> createState() => _AdvancedOptionsWidgetState();
}

class _AdvancedOptionsWidgetState extends State<AdvancedOptionsWidget> {
  bool _isExpanded = false;
  final TextEditingController _hashtagController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final List<Map<String, dynamic>> suggestedHashtags = [
    {"tag": "#SocialMediaMarketing", "popularity": "High", "posts": "2.1M"},
    {"tag": "#DigitalMarketing", "popularity": "High", "posts": "3.5M"},
    {"tag": "#ContentCreation", "popularity": "Medium", "posts": "890K"},
    {"tag": "#MarketingTips", "popularity": "Medium", "posts": "1.2M"},
    {"tag": "#BusinessGrowth", "popularity": "High", "posts": "1.8M"},
    {"tag": "#OnlineMarketing", "popularity": "Medium", "posts": "950K"},
    {"tag": "#BrandStrategy", "popularity": "Low", "posts": "340K"},
    {"tag": "#MarketingStrategy", "popularity": "High", "posts": "2.3M"},
  ];

  final List<String> audienceOptions = [
    "Public",
    "Followers Only",
    "Close Friends",
    "Custom Audience",
  ];

  final List<Map<String, dynamic>> locationSuggestions = [
    {"name": "Bangkok, Thailand", "type": "City"},
    {"name": "Chiang Mai, Thailand", "type": "City"},
    {"name": "Phuket, Thailand", "type": "City"},
    {"name": "Siam Paragon", "type": "Business"},
    {"name": "CentralWorld", "type": "Business"},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.selectedLocation != null) {
      _locationController.text = widget.selectedLocation!;
    }
  }

  @override
  void dispose() {
    _hashtagController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _addHashtag(String hashtag) {
    if (!widget.selectedHashtags.contains(hashtag)) {
      List<String> updatedHashtags = List.from(widget.selectedHashtags);
      updatedHashtags.add(hashtag);
      widget.onHashtagsChanged(updatedHashtags);
    }
  }

  void _removeHashtag(String hashtag) {
    List<String> updatedHashtags = List.from(widget.selectedHashtags);
    updatedHashtags.remove(hashtag);
    widget.onHashtagsChanged(updatedHashtags);
  }

  void _addCustomHashtag() {
    String hashtag = _hashtagController.text.trim();
    if (hashtag.isNotEmpty) {
      if (!hashtag.startsWith('#')) {
        hashtag = '#$hashtag';
      }
      _addHashtag(hashtag);
      _hashtagController.clear();
    }
  }

  void _selectLocation(String location) {
    _locationController.text = location;
    widget.onLocationChanged(location);
  }

  Color _getPopularityColor(String popularity) {
    switch (popularity.toLowerCase()) {
      case 'high':
        return AppTheme.successLight;
      case 'medium':
        return AppTheme.warningLight;
      case 'low':
        return AppTheme.errorLight;
      default:
        return AppTheme.getTextColor(context, secondary: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Advanced Options',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextColor(context),
                  ),
                ),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: CustomIconWidget(
                    iconName: 'keyboard_arrow_down',
                    size: 6.w,
                    color: AppTheme.getTextColor(context, secondary: true),
                  ),
                ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isExpanded ? null : 0,
            child: _isExpanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2.h),

                      // Hashtags Section
                      Text(
                        'Hashtags',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTextColor(context),
                        ),
                      ),
                      SizedBox(height: 1.h),

                      // Custom Hashtag Input
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _hashtagController,
                              decoration: InputDecoration(
                                hintText: 'Add custom hashtag...',
                                prefixText: '#',
                                prefixStyle: AppTheme
                                    .lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: AppTheme.lightTheme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: _addCustomHashtag,
                                  icon: CustomIconWidget(
                                    iconName: 'add',
                                    size: 5.w,
                                    color: AppTheme.lightTheme.primaryColor,
                                  ),
                                ),
                              ),
                              onSubmitted: (_) => _addCustomHashtag(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.5.h),

                      // Selected Hashtags
                      if (widget.selectedHashtags.isNotEmpty) ...[
                        Text(
                          'Selected (${widget.selectedHashtags.length})',
                          style: AppTheme.lightTheme.textTheme.labelMedium
                              ?.copyWith(
                            color:
                                AppTheme.getTextColor(context, secondary: true),
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Wrap(
                          spacing: 2.w,
                          runSpacing: 1.h,
                          children: widget.selectedHashtags.map((hashtag) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 3.w, vertical: 1.h),
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.primaryColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    hashtag,
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  GestureDetector(
                                    onTap: () => _removeHashtag(hashtag),
                                    child: CustomIconWidget(
                                      iconName: 'close',
                                      size: 3.w,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 2.h),
                      ],

                      // Suggested Hashtags
                      Text(
                        'Suggested Hashtags',
                        style:
                            AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                          color:
                              AppTheme.getTextColor(context, secondary: true),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      SizedBox(
                        height: 12.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: suggestedHashtags.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(width: 2.w),
                          itemBuilder: (context, index) {
                            final hashtag = suggestedHashtags[index];
                            final isSelected = widget.selectedHashtags
                                .contains(hashtag["tag"]);

                            return GestureDetector(
                              onTap: () => isSelected
                                  ? _removeHashtag(hashtag["tag"] as String)
                                  : _addHashtag(hashtag["tag"] as String),
                              child: Container(
                                width: 40.w,
                                padding: EdgeInsets.all(2.w),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.lightTheme.primaryColor
                                          .withValues(alpha: 0.1)
                                      : AppTheme.getSurfaceColor(context),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.lightTheme.primaryColor
                                        : AppTheme.getBorderColor(context),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 1.5.w,
                                              vertical: 0.5.h),
                                          decoration: BoxDecoration(
                                            color: _getPopularityColor(
                                                    hashtag["popularity"]
                                                        as String)
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            hashtag["popularity"] as String,
                                            style: AppTheme
                                                .lightTheme.textTheme.labelSmall
                                                ?.copyWith(
                                              color: _getPopularityColor(
                                                  hashtag["popularity"]
                                                      as String),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        if (isSelected)
                                          CustomIconWidget(
                                            iconName: 'check_circle',
                                            size: 4.w,
                                            color: AppTheme
                                                .lightTheme.primaryColor,
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 1.h),
                                    Text(
                                      hashtag["tag"] as String,
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: AppTheme.getTextColor(context),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 0.5.h),
                                    Text(
                                      '${hashtag["posts"]} posts',
                                      style: AppTheme
                                          .lightTheme.textTheme.labelSmall
                                          ?.copyWith(
                                        color: AppTheme.getTextColor(context,
                                            secondary: true),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 3.h),

                      // Location Section
                      Text(
                        'Location',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTextColor(context),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      TextField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          hintText: 'Add location...',
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(3.w),
                            child: CustomIconWidget(
                              iconName: 'location_on',
                              size: 5.w,
                              color: AppTheme.lightTheme.primaryColor,
                            ),
                          ),
                          suffixIcon: widget.selectedLocation != null
                              ? IconButton(
                                  onPressed: () {
                                    _locationController.clear();
                                    widget.onLocationChanged(null);
                                  },
                                  icon: CustomIconWidget(
                                    iconName: 'clear',
                                    size: 5.w,
                                    color: AppTheme.getTextColor(context,
                                        secondary: true),
                                  ),
                                )
                              : null,
                        ),
                        onChanged: (value) => widget
                            .onLocationChanged(value.isEmpty ? null : value),
                      ),
                      SizedBox(height: 1.h),

                      // Location Suggestions
                      SizedBox(
                        height: 8.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: locationSuggestions.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(width: 2.w),
                          itemBuilder: (context, index) {
                            final location = locationSuggestions[index];
                            return GestureDetector(
                              onTap: () =>
                                  _selectLocation(location["name"] as String),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 3.w, vertical: 1.5.h),
                                decoration: BoxDecoration(
                                  color: AppTheme.getSurfaceColor(context),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppTheme.getBorderColor(context),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CustomIconWidget(
                                      iconName: location["type"] == "City"
                                          ? 'location_city'
                                          : 'business',
                                      size: 4.w,
                                      color: AppTheme.lightTheme.primaryColor,
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      location["name"] as String,
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: AppTheme.getTextColor(context),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 3.h),

                      // Audience Section
                      Text(
                        'Audience',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTextColor(context),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: audienceOptions.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 1.h),
                        itemBuilder: (context, index) {
                          final option = audienceOptions[index];
                          final isSelected = widget.selectedAudience == option;

                          return GestureDetector(
                            onTap: () => widget.onAudienceChanged(option),
                            child: Container(
                              padding: EdgeInsets.all(3.w),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.lightTheme.primaryColor
                                        .withValues(alpha: 0.1)
                                    : AppTheme.getSurfaceColor(context),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.lightTheme.primaryColor
                                      : AppTheme.getBorderColor(context),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Radio<String>(
                                    value: option,
                                    groupValue: widget.selectedAudience,
                                    onChanged: (value) =>
                                        widget.onAudienceChanged(value!),
                                    activeColor:
                                        AppTheme.lightTheme.primaryColor,
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: AppTheme
                                          .lightTheme.textTheme.bodyMedium
                                          ?.copyWith(
                                        color: AppTheme.getTextColor(context),
                                        fontWeight: isSelected
                                            ? FontWeight.w500
                                            : FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
