import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PlatformPreviewWidget extends StatefulWidget {
  final List<String> selectedPlatforms;
  final String content;
  final List<String> hashtags;
  final String? location;

  const PlatformPreviewWidget({
    Key? key,
    required this.selectedPlatforms,
    required this.content,
    required this.hashtags,
    this.location,
  }) : super(key: key);

  @override
  State<PlatformPreviewWidget> createState() => _PlatformPreviewWidgetState();
}

class _PlatformPreviewWidgetState extends State<PlatformPreviewWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final Map<String, Map<String, dynamic>> platformData = {
    "instagram": {
      "name": "Instagram",
      "color": Color(0xFFE4405F),
      "icon": "camera_alt",
      "username": "@mybrand_official",
      "verified": true,
    },
    "facebook": {
      "name": "Facebook",
      "color": Color(0xFF1877F2),
      "icon": "facebook",
      "username": "My Brand Page",
      "verified": true,
    },
    "twitter": {
      "name": "Twitter",
      "color": Color(0xFF1DA1F2),
      "icon": "alternate_email",
      "username": "@mybrand",
      "verified": false,
    },
    "linkedin": {
      "name": "LinkedIn",
      "color": Color(0xFF0A66C2),
      "icon": "business",
      "username": "My Brand Company",
      "verified": true,
    },
    "tiktok": {
      "name": "TikTok",
      "color": Color(0xFF000000),
      "icon": "music_note",
      "username": "@mybrand_th",
      "verified": false,
    },
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.selectedPlatforms.length,
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(PlatformPreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedPlatforms.length != widget.selectedPlatforms.length) {
      _tabController.dispose();
      _tabController = TabController(
        length: widget.selectedPlatforms.length,
        vsync: this,
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatContentForPlatform(String platformId) {
    String formattedContent = widget.content;

    // Add hashtags if any
    if (widget.hashtags.isNotEmpty) {
      String hashtagString = widget.hashtags.join(' ');
      formattedContent += '\n\n$hashtagString';
    }

    // Add location if available
    if (widget.location != null && widget.location!.isNotEmpty) {
      formattedContent += '\n📍 ${widget.location}';
    }

    return formattedContent;
  }

  Widget _buildInstagramPreview() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getBorderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(3.w),
            child: Row(
              children: [
                Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFE4405F),
                        Color(0xFFFD1D1D),
                        Color(0xFFFFDC80)
                      ],
                    ),
                  ),
                  child: Container(
                    margin: EdgeInsets.all(0.5.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.getSurfaceColor(context),
                    ),
                    child: CustomImageWidget(
                      imageUrl:
                          "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face",
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
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
                            platformData["instagram"]!["username"] as String,
                            style: AppTheme.lightTheme.textTheme.titleSmall
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (platformData["instagram"]!["verified"]
                              as bool) ...[
                            SizedBox(width: 1.w),
                            CustomIconWidget(
                              iconName: 'verified',
                              size: 4.w,
                              color: const Color(0xFF1DA1F2),
                            ),
                          ],
                        ],
                      ),
                      if (widget.location != null &&
                          widget.location!.isNotEmpty)
                        Text(
                          widget.location!,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color:
                                AppTheme.getTextColor(context, secondary: true),
                          ),
                        ),
                    ],
                  ),
                ),
                CustomIconWidget(
                  iconName: 'more_vert',
                  size: 6.w,
                  color: AppTheme.getTextColor(context),
                ),
              ],
            ),
          ),

          // Image placeholder
          Container(
            width: double.infinity,
            height: 60.w,
            color: Colors.grey.shade200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'photo_camera',
                    size: 12.w,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Your media will appear here',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Actions
          Padding(
            padding: EdgeInsets.all(3.w),
            child: Row(
              children: [
                CustomIconWidget(
                    iconName: 'favorite_border',
                    size: 6.w,
                    color: AppTheme.getTextColor(context)),
                SizedBox(width: 4.w),
                CustomIconWidget(
                    iconName: 'chat_bubble_outline',
                    size: 6.w,
                    color: AppTheme.getTextColor(context)),
                SizedBox(width: 4.w),
                CustomIconWidget(
                    iconName: 'send',
                    size: 6.w,
                    color: AppTheme.getTextColor(context)),
                const Spacer(),
                CustomIconWidget(
                    iconName: 'bookmark_border',
                    size: 6.w,
                    color: AppTheme.getTextColor(context)),
              ],
            ),
          ),

          // Content
          if (widget.content.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: RichText(
                text: TextSpan(
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.getTextColor(context),
                  ),
                  children: [
                    TextSpan(
                      text: '${platformData["instagram"]!["username"]} ',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: _formatContentForPlatform("instagram")),
                  ],
                ),
              ),
            ),
          SizedBox(height: 3.w),
        ],
      ),
    );
  }

  Widget _buildTwitterPreview() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getBorderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: ClipOval(
                  child: CustomImageWidget(
                    imageUrl:
                        "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face",
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
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
                          'My Brand',
                          style: AppTheme.lightTheme.textTheme.titleSmall
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          platformData["twitter"]!["username"] as String,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color:
                                AppTheme.getTextColor(context, secondary: true),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          '• 2h',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color:
                                AppTheme.getTextColor(context, secondary: true),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    if (widget.content.isNotEmpty)
                      Text(
                        _formatContentForPlatform("twitter"),
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.getTextColor(context),
                        ),
                      ),
                    SizedBox(height: 2.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CustomIconWidget(
                                iconName: 'chat_bubble_outline',
                                size: 4.w,
                                color: AppTheme.getTextColor(context,
                                    secondary: true)),
                            SizedBox(width: 1.w),
                            Text('12',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                        color: AppTheme.getTextColor(context,
                                            secondary: true))),
                          ],
                        ),
                        Row(
                          children: [
                            CustomIconWidget(
                                iconName: 'repeat',
                                size: 4.w,
                                color: AppTheme.getTextColor(context,
                                    secondary: true)),
                            SizedBox(width: 1.w),
                            Text('5',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                        color: AppTheme.getTextColor(context,
                                            secondary: true))),
                          ],
                        ),
                        Row(
                          children: [
                            CustomIconWidget(
                                iconName: 'favorite_border',
                                size: 4.w,
                                color: AppTheme.getTextColor(context,
                                    secondary: true)),
                            SizedBox(width: 1.w),
                            Text('23',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                        color: AppTheme.getTextColor(context,
                                            secondary: true))),
                          ],
                        ),
                        CustomIconWidget(
                            iconName: 'share',
                            size: 4.w,
                            color: AppTheme.getTextColor(context,
                                secondary: true)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFacebookPreview() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getBorderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: ClipOval(
                  child: CustomImageWidget(
                    imageUrl:
                        "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face",
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
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
                          platformData["facebook"]!["username"] as String,
                          style: AppTheme.lightTheme.textTheme.titleSmall
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (platformData["facebook"]!["verified"] as bool) ...[
                          SizedBox(width: 1.w),
                          CustomIconWidget(
                            iconName: 'verified',
                            size: 4.w,
                            color: const Color(0xFF1877F2),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '2 hours ago • 🌍',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.getTextColor(context, secondary: true),
                      ),
                    ),
                  ],
                ),
              ),
              CustomIconWidget(
                iconName: 'more_horiz',
                size: 6.w,
                color: AppTheme.getTextColor(context, secondary: true),
              ),
            ],
          ),
          if (widget.content.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Text(
              _formatContentForPlatform("facebook"),
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.getTextColor(context),
              ),
            ),
          ],
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            height: 40.w,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'photo_camera',
                    size: 10.w,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Your media will appear here',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                      iconName: 'thumb_up',
                      size: 5.w,
                      color: AppTheme.getTextColor(context, secondary: true)),
                  SizedBox(width: 2.w),
                  Text('Like',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.getTextColor(context, secondary: true))),
                ],
              ),
              Row(
                children: [
                  CustomIconWidget(
                      iconName: 'comment',
                      size: 5.w,
                      color: AppTheme.getTextColor(context, secondary: true)),
                  SizedBox(width: 2.w),
                  Text('Comment',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.getTextColor(context, secondary: true))),
                ],
              ),
              Row(
                children: [
                  CustomIconWidget(
                      iconName: 'share',
                      size: 5.w,
                      color: AppTheme.getTextColor(context, secondary: true)),
                  SizedBox(width: 2.w),
                  Text('Share',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.getTextColor(context, secondary: true))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLinkedInPreview() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getBorderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: ClipOval(
                  child: CustomImageWidget(
                    imageUrl:
                        "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face",
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      platformData["linkedin"]!["username"] as String,
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Marketing Director • 2h',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.getTextColor(context, secondary: true),
                      ),
                    ),
                  ],
                ),
              ),
              CustomIconWidget(
                iconName: 'more_vert',
                size: 6.w,
                color: AppTheme.getTextColor(context, secondary: true),
              ),
            ],
          ),
          if (widget.content.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Text(
              _formatContentForPlatform("linkedin"),
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.getTextColor(context),
              ),
            ),
          ],
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                      iconName: 'thumb_up',
                      size: 4.w,
                      color: AppTheme.getTextColor(context, secondary: true)),
                  SizedBox(width: 1.w),
                  Text('15',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.getTextColor(context, secondary: true))),
                ],
              ),
              Text('3 comments',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.getTextColor(context, secondary: true))),
            ],
          ),
          SizedBox(height: 1.h),
          Divider(color: AppTheme.getBorderColor(context)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                      iconName: 'thumb_up',
                      size: 5.w,
                      color: AppTheme.getTextColor(context, secondary: true)),
                  SizedBox(width: 2.w),
                  Text('Like',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.getTextColor(context, secondary: true))),
                ],
              ),
              Row(
                children: [
                  CustomIconWidget(
                      iconName: 'comment',
                      size: 5.w,
                      color: AppTheme.getTextColor(context, secondary: true)),
                  SizedBox(width: 2.w),
                  Text('Comment',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.getTextColor(context, secondary: true))),
                ],
              ),
              Row(
                children: [
                  CustomIconWidget(
                      iconName: 'share',
                      size: 5.w,
                      color: AppTheme.getTextColor(context, secondary: true)),
                  SizedBox(width: 2.w),
                  Text('Share',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.getTextColor(context, secondary: true))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTikTokPreview() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: ClipOval(
                  child: CustomImageWidget(
                    imageUrl:
                        "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face",
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      platformData["tiktok"]!["username"] as String,
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'My Brand • 2h ago',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              CustomIconWidget(
                iconName: 'more_vert',
                size: 6.w,
                color: Colors.white,
              ),
            ],
          ),
          if (widget.content.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Text(
              _formatContentForPlatform("tiktok"),
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
            ),
          ],
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            height: 60.w,
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'videocam',
                    size: 12.w,
                    color: Colors.white54,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Your video will appear here',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewForPlatform(String platformId) {
    switch (platformId) {
      case 'instagram':
        return _buildInstagramPreview();
      case 'twitter':
        return _buildTwitterPreview();
      case 'facebook':
        return _buildFacebookPreview();
      case 'linkedin':
        return _buildLinkedInPreview();
      case 'tiktok':
        return _buildTikTokPreview();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedPlatforms.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: 'preview',
              size: 12.w,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 2.h),
            Text(
              'Select platforms to see preview',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Platform Preview',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextColor(context),
            ),
          ),
          SizedBox(height: 1.5.h),
          if (widget.selectedPlatforms.length == 1)
            _buildPreviewForPlatform(widget.selectedPlatforms.first)
          else
            Column(
              children: [
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: widget.selectedPlatforms.map((platformId) {
                    final platform = platformData[platformId]!;
                    return Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: BoxDecoration(
                              color: platform["color"] as Color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: CustomIconWidget(
                                iconName: platform["icon"] as String,
                                size: 3.w,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Text(platform["name"] as String),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 2.h),
                SizedBox(
                  height: 80.h,
                  child: TabBarView(
                    controller: _tabController,
                    children: widget.selectedPlatforms.map((platformId) {
                      return SingleChildScrollView(
                        child: _buildPreviewForPlatform(platformId),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
