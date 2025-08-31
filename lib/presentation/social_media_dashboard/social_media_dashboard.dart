import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/account_overview_widget.dart';
import './widgets/activity_feed_widget.dart';
import './widgets/performance_widgets.dart';
import './widgets/quick_actions_widget.dart';
import './widgets/scheduled_content_widget.dart';

class SocialMediaDashboard extends StatefulWidget {
  const SocialMediaDashboard({Key? key}) : super(key: key);

  @override
  State<SocialMediaDashboard> createState() => _SocialMediaDashboardState();
}

class _SocialMediaDashboardState extends State<SocialMediaDashboard>
    with TickerProviderStateMixin {
  bool _isRefreshing = false;
  late TabController _tabController;

  // Mock data for connected accounts
  final List<Map<String, dynamic>> _connectedAccounts = [
    {
      "platform": "Facebook",
      "username": "@ai_social_hub",
      "followers": 15420,
      "engagement": 8.5,
      "reach": 45230,
      "trend": "up",
      "color": Color(0xFF1877F2),
      "isConnected": true,
    },
    {
      "platform": "Instagram",
      "username": "@aisocialhub",
      "followers": 8750,
      "engagement": 12.3,
      "reach": 28940,
      "trend": "up",
      "color": Color(0xFFE4405F),
      "isConnected": true,
    },
    {
      "platform": "Twitter",
      "username": "@ai_social_hub",
      "followers": 3250,
      "engagement": 6.2,
      "reach": 12450,
      "trend": "down",
      "color": Color(0xFF1DA1F2),
      "isConnected": true,
    },
    {
      "platform": "LinkedIn",
      "username": "AI Social Hub",
      "followers": 2100,
      "engagement": 9.8,
      "reach": 8750,
      "trend": "up",
      "color": Color(0xFF0077B5),
      "isConnected": true,
    }
  ];

  // Mock data for activity feed
  final List<Map<String, dynamic>> _activityFeed = [
    {
      "id": 1,
      "type": "comment",
      "platform": "Instagram",
      "content": "ขอบคุณสำหรับเนื้อหาดีๆ นะครับ! 👍",
      "timestamp": DateTime.now().subtract(Duration(minutes: 15)),
      "author": "user_123",
      "postTitle": "Tips การใช้ AI ในการจัดการโซเชียลมีเดีย",
      "requiresAttention": true,
      "engagementCount": 5,
    },
    {
      "id": 2,
      "type": "mention",
      "platform": "Twitter",
      "content":
          "Great insights from @ai_social_hub about social media automation!",
      "timestamp": DateTime.now().subtract(Duration(minutes: 32)),
      "author": "marketing_pro",
      "requiresAttention": true,
      "engagementCount": 12,
    },
    {
      "id": 3,
      "type": "message",
      "platform": "Facebook",
      "content": "สอบถามเรื่องแพ็คเกจ premium หน่อยครับ",
      "timestamp": DateTime.now().subtract(Duration(hours: 1, minutes: 5)),
      "author": "potential_customer",
      "requiresAttention": true,
      "engagementCount": 0,
    },
    {
      "id": 4,
      "type": "like",
      "platform": "LinkedIn",
      "content": "Your post about AI trends got 50 new likes",
      "timestamp": DateTime.now().subtract(Duration(hours: 2)),
      "postTitle": "AI Trends in Social Media Management 2025",
      "requiresAttention": false,
      "engagementCount": 50,
    }
  ];

  // Mock data for performance insights
  final Map<String, dynamic> _performanceData = {
    "topPerformingPost": {
      "title": "เปิดตัวฟีเจอร์ใหม่ AI Content Generator",
      "platform": "Instagram",
      "engagement": 245,
      "reach": 5420,
      "imageUrl":
          "https://images.unsplash.com/photo-1677442136019-21780ecad995?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
    },
    "scheduledPostsCount": 12,
    "aiInsight":
        "เนื้อหาที่โพสต์ในช่วงเย็น (17:00-19:00) มีการมีส่วนร่วมสูงกว่า 35% เมื่อเทียบกับช่วงเช้า"
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppTheme.lightTheme.primaryColor,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 2.h),
              AccountOverviewWidget(
                connectedAccounts: _connectedAccounts,
                onAccountTap: _onAccountTap,
              ),
              SizedBox(height: 3.h),
              PerformanceWidget(
                performanceData: _performanceData,
                onViewAnalytics: _onViewAnalytics,
              ),
              SizedBox(height: 3.h),
              QuickActionsWidget(
                onCreatePost: _onCreatePost,
                onViewAnalytics: _onViewAnalytics,
                onManageTeam: _onManageTeam,
              ),
              SizedBox(height: 3.h),
              ActivityFeedWidget(
                activities: _activityFeed,
                onActivityTap: _onActivityTap,
                onReply: _onReply,
                onLike: _onLike,
                onShare: _onShare,
              ),
              SizedBox(height: 3.h),
              ScheduledContentWidget(
                scheduledCount: _performanceData["scheduledPostsCount"] as int,
                onViewSchedule: _onViewSchedule,
                onCreatePost: _onCreatePost,
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onCreatePost,
        child: CustomIconWidget(
          iconName: 'add',
          size: 24,
          color: Colors.white,
        ),
        backgroundColor: AppTheme.lightTheme.primaryColor,
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Social Media Dashboard',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.getTextColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'มีส่วนร่วมในวันนี้: 127 รายการ',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.getTextColor(context, secondary: true),
            ),
          ),
        ],
      ),
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: _onNotificationsPressed,
          icon: Stack(
            children: [
              CustomIconWidget(
                iconName: 'notifications',
                size: 24,
                color: AppTheme.getTextColor(context),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Color(0xFFDC2626),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _onSettingsPressed,
          icon: CustomIconWidget(
            iconName: 'settings',
            size: 24,
            color: AppTheme.getTextColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: AppTheme.getBorderColor(context),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: [
          Tab(
            icon: CustomIconWidget(
              iconName: 'dashboard',
              size: 24,
              color: _tabController.index == 0
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.getTextColor(context, secondary: true),
            ),
            text: 'แดชบอร์ด',
          ),
          Tab(
            icon: CustomIconWidget(
              iconName: 'calendar_today',
              size: 24,
              color: _tabController.index == 1
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.getTextColor(context, secondary: true),
            ),
            text: 'ปฏิทิน',
          ),
          Tab(
            icon: CustomIconWidget(
              iconName: 'message',
              size: 24,
              color: _tabController.index == 2
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.getTextColor(context, secondary: true),
            ),
            text: 'ข้อความ',
          ),
          Tab(
            icon: CustomIconWidget(
              iconName: 'person',
              size: 24,
              color: _tabController.index == 3
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.getTextColor(context, secondary: true),
            ),
            text: 'โปรไฟล์',
          ),
        ],
        labelColor: AppTheme.lightTheme.primaryColor,
        unselectedLabelColor: AppTheme.getTextColor(context, secondary: true),
        indicatorColor: AppTheme.lightTheme.primaryColor,
        labelStyle: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle:
            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w400,
        ),
        onTap: _onTabChanged,
      ),
    );
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate API call
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });

    HapticFeedback.lightImpact();
  }

  void _onAccountTap(Map<String, dynamic> account) {
    HapticFeedback.lightImpact();
    _showAccountDetails(account);
  }

  void _onActivityTap(Map<String, dynamic> activity) {
    HapticFeedback.lightImpact();
    _showActivityDetails(activity);
  }

  void _onReply(Map<String, dynamic> activity) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, AppRoutes.messagesInbox, arguments: activity);
  }

  void _onLike(Map<String, dynamic> activity) {
    HapticFeedback.selectionClick();
    // Handle like action
  }

  void _onShare(Map<String, dynamic> activity) {
    HapticFeedback.lightImpact();
    // Handle share action
  }

  void _onCreatePost() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, AppRoutes.postCreation);
  }

  void _onViewAnalytics() {
    HapticFeedback.lightImpact();
    // Navigate to analytics screen
  }

  void _onManageTeam() {
    HapticFeedback.lightImpact();
    // Navigate to team management screen
  }

  void _onViewSchedule() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, AppRoutes.contentCalendar);
  }

  void _onNotificationsPressed() {
    HapticFeedback.lightImpact();
    // Show notifications
  }

  void _onSettingsPressed() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, AppRoutes.userProfile);
  }

  void _onTabChanged(int index) {
    HapticFeedback.selectionClick();
    switch (index) {
      case 0:
        // Current screen
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.contentCalendar);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.messagesInbox);
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.userProfile);
        break;
    }
  }

  void _showAccountDetails(Map<String, dynamic> account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: account['color'] as Color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: account['platform'].toString().toLowerCase(),
                color: Colors.white,
                size: 20,
              ),
            ),
            SizedBox(width: 3.w),
            Text(account['platform'] as String),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ชื่อผู้ใช้: ${account['username']}'),
            SizedBox(height: 1.h),
            Text('ผู้ติดตาม: ${account['followers']}'),
            SizedBox(height: 1.h),
            Text('การมีส่วนร่วม: ${account['engagement']}%'),
            SizedBox(height: 1.h),
            Text('ครอบคลุม: ${account['reach']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ปิด'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to detailed analytics
            },
            child: Text('ดูรายละเอียด'),
          ),
        ],
      ),
    );
  }

  void _showActivityDetails(Map<String, dynamic> activity) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
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
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color:
                              _getPlatformColor(activity['platform'] as String),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomIconWidget(
                          iconName:
                              activity['platform'].toString().toLowerCase(),
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity['platform'] as String,
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _formatActivityTime(
                                  activity['timestamp'] as DateTime),
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.getTextColor(context,
                                    secondary: true),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    activity['content'] as String,
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _onReply(activity);
                        },
                        child: Text('ตอบกลับ'),
                      ),
                      SizedBox(width: 2.w),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _onLike(activity);
                        },
                        child: Text('ถูกใจ'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
        return Color(0xFF0077B5);
      default:
        return AppTheme.lightTheme.primaryColor;
    }
  }

  String _formatActivityTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} นาทีที่แล้ว';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ชั่วโมงที่แล้ว';
    } else {
      return '${difference.inDays} วันที่แล้ว';
    }
  }
}
