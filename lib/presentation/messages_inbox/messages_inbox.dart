import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/conversation_list_widget.dart';
import './widgets/message_filter_widget.dart';
import './widgets/platform_tabs_widget.dart';
import './widgets/search_bar_widget.dart';

class MessagesInbox extends StatefulWidget {
  const MessagesInbox({Key? key}) : super(key: key);

  @override
  State<MessagesInbox> createState() => _MessagesInboxState();
}

class _MessagesInboxState extends State<MessagesInbox>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TabController _platformTabController;
  String _selectedFilter = 'all';
  String _searchQuery = '';
  bool _isRefreshing = false;

  // Mock data for conversations
  final List<Map<String, dynamic>> _conversations = [
    {
      "id": 1,
      "platform": "Instagram",
      "senderName": "Sarah_Marketing",
      "senderAvatar":
          "https://images.unsplash.com/photo-1494790108755-2616b2fb1d0f?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "lastMessage": "สวัสดีครับ อยากสอบถามเรื่องแพ็คเกจ Premium หน่อยครับ",
      "timestamp": DateTime.now().subtract(Duration(minutes: 5)),
      "isRead": false,
      "unreadCount": 3,
      "isOnline": true,
      "isPriority": true,
      "messageType": "text",
      "platformColor": Color(0xFFE4405F),
    },
    {
      "id": 2,
      "platform": "Facebook",
      "senderName": "John Smith",
      "senderAvatar":
          "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "lastMessage": "ขอบคุณสำหรับข้อมูลครับ จะลองใช้ดู",
      "timestamp": DateTime.now().subtract(Duration(minutes: 15)),
      "isRead": true,
      "unreadCount": 0,
      "isOnline": false,
      "isPriority": false,
      "messageType": "text",
      "platformColor": Color(0xFF1877F2),
    },
    {
      "id": 3,
      "platform": "Twitter",
      "senderName": "TechInfluencer",
      "senderAvatar":
          "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "lastMessage": "Would love to collaborate on content about AI trends! 🚀",
      "timestamp": DateTime.now().subtract(Duration(hours: 1)),
      "isRead": false,
      "unreadCount": 1,
      "isOnline": true,
      "isPriority": true,
      "messageType": "text",
      "platformColor": Color(0xFF1DA1F2),
    },
    {
      "id": 4,
      "platform": "LinkedIn",
      "senderName": "Marketing Agency",
      "senderAvatar":
          "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "lastMessage": "Sent you a document about partnership proposal",
      "timestamp": DateTime.now().subtract(Duration(hours: 2)),
      "isRead": true,
      "unreadCount": 0,
      "isOnline": false,
      "isPriority": false,
      "messageType": "document",
      "platformColor": Color(0xFF0077B5),
    },
    {
      "id": 5,
      "platform": "Instagram",
      "senderName": "ContentCreator99",
      "senderAvatar":
          "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "lastMessage": "📸 Sent a photo",
      "timestamp": DateTime.now().subtract(Duration(hours: 3)),
      "isRead": false,
      "unreadCount": 2,
      "isOnline": true,
      "isPriority": false,
      "messageType": "image",
      "platformColor": Color(0xFFE4405F),
    },
    {
      "id": 6,
      "platform": "Facebook",
      "senderName": "Local Business Owner",
      "senderAvatar":
          "https://images.unsplash.com/photo-1463453091185-61582044d556?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "lastMessage": "เมื่อไหร่จะมี workshop ใหม่อีกครับ?",
      "timestamp": DateTime.now().subtract(Duration(days: 1)),
      "isRead": true,
      "unreadCount": 0,
      "isOnline": false,
      "isPriority": false,
      "messageType": "text",
      "platformColor": Color(0xFF1877F2),
    }
  ];

  final List<String> _platforms = [
    'All',
    'Instagram',
    'Facebook',
    'Twitter',
    'LinkedIn'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 2);
    _platformTabController =
        TabController(length: _platforms.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _platformTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          SearchBarWidget(
            onSearchChanged: _onSearchChanged,
            onFilterPressed: _onFilterPressed,
          ),
          PlatformTabsWidget(
            platforms: _platforms,
            controller: _platformTabController,
            onTabChanged: _onPlatformTabChanged,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              color: AppTheme.lightTheme.primaryColor,
              child: ConversationListWidget(
                conversations: _getFilteredConversations(),
                onConversationTap: _onConversationTap,
                onConversationSwipe: _onConversationSwipe,
                onQuickReply: _onQuickReply,
                onMarkAsRead: _onMarkAsRead,
                onArchive: _onArchiveConversation,
                onDelete: _onDeleteConversation,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onComposeMessage,
        child: CustomIconWidget(
          iconName: 'edit',
          size: 24,
          color: Colors.white,
        ),
        backgroundColor: AppTheme.lightTheme.primaryColor,
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final unreadCount = _conversations.where((c) => !c['isRead']).length;

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Messages Inbox',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.getTextColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'ข้อความที่ยังไม่อ่าน: $unreadCount รายการ',
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
          onPressed: _onBulkActionPressed,
          icon: CustomIconWidget(
            iconName: 'checklist',
            size: 24,
            color: AppTheme.getTextColor(context),
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
            icon: Stack(
              children: [
                CustomIconWidget(
                  iconName: 'message',
                  size: 24,
                  color: _tabController.index == 2
                      ? AppTheme.lightTheme.primaryColor
                      : AppTheme.getTextColor(context, secondary: true),
                ),
                if (_conversations.where((c) => !c['isRead']).isNotEmpty)
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

  List<Map<String, dynamic>> _getFilteredConversations() {
    List<Map<String, dynamic>> filtered = _conversations;

    // Filter by platform
    if (_platformTabController.index > 0) {
      final selectedPlatform = _platforms[_platformTabController.index];
      filtered =
          filtered.where((c) => c['platform'] == selectedPlatform).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((c) {
        final senderName = (c['senderName'] as String).toLowerCase();
        final lastMessage = (c['lastMessage'] as String).toLowerCase();
        return senderName.contains(_searchQuery.toLowerCase()) ||
            lastMessage.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filter by status
    switch (_selectedFilter) {
      case 'unread':
        filtered = filtered.where((c) => !c['isRead']).toList();
        break;
      case 'priority':
        filtered = filtered.where((c) => c['isPriority']).toList();
        break;
      case 'online':
        filtered = filtered.where((c) => c['isOnline']).toList();
        break;
    }

    // Sort by timestamp (newest first)
    filtered.sort((a, b) =>
        (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));

    return filtered;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _onFilterPressed() {
    HapticFeedback.lightImpact();
    _showFilterOptions();
  }

  void _onPlatformTabChanged(int index) {
    setState(() {});
    HapticFeedback.selectionClick();
  }

  void _onConversationTap(Map<String, dynamic> conversation) {
    HapticFeedback.lightImpact();
    _openConversationDetail(conversation);
  }

  void _onConversationSwipe(Map<String, dynamic> conversation, String action) {
    HapticFeedback.mediumImpact();
    switch (action) {
      case 'reply':
        _onQuickReply(conversation);
        break;
      case 'markRead':
        _onMarkAsRead(conversation);
        break;
      case 'archive':
        _onArchiveConversation(conversation);
        break;
      case 'delete':
        _onDeleteConversation(conversation);
        break;
    }
  }

  void _onQuickReply(Map<String, dynamic> conversation) {
    HapticFeedback.lightImpact();
    _showQuickReplySheet(conversation);
  }

  void _onMarkAsRead(Map<String, dynamic> conversation) {
    setState(() {
      conversation['isRead'] = true;
      conversation['unreadCount'] = 0;
    });
    HapticFeedback.selectionClick();
  }

  void _onArchiveConversation(Map<String, dynamic> conversation) {
    setState(() {
      _conversations.remove(conversation);
    });
    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('เก็บถาวรการสนทนาแล้ว'),
        action: SnackBarAction(
          label: 'เลิกทำ',
          onPressed: () {
            setState(() {
              _conversations.add(conversation);
            });
          },
        ),
      ),
    );
  }

  void _onDeleteConversation(Map<String, dynamic> conversation) {
    HapticFeedback.mediumImpact();
    _showDeleteConfirmation(conversation);
  }

  void _onComposeMessage() {
    HapticFeedback.lightImpact();
    _showComposeMessageSheet();
  }

  void _onBulkActionPressed() {
    HapticFeedback.lightImpact();
    _showBulkActionSheet();
  }

  void _onSettingsPressed() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, AppRoutes.userProfile);
  }

  void _onTabChanged(int index) {
    HapticFeedback.selectionClick();
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.socialMediaDashboard);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.contentCalendar);
        break;
      case 2:
        // Current screen
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.userProfile);
        break;
    }
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

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => MessageFilterWidget(
        selectedFilter: _selectedFilter,
        onFilterChanged: (filter) {
          setState(() {
            _selectedFilter = filter;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _openConversationDetail(Map<String, dynamic> conversation) {
    // Mark as read
    setState(() {
      conversation['isRead'] = true;
      conversation['unreadCount'] = 0;
    });

    // Navigate to individual conversation screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ConversationDetailScreen(
          conversation: conversation,
        ),
      ),
    );
  }

  void _showQuickReplySheet(Map<String, dynamic> conversation) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: 40.h,
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
                          color: conversation['platformColor'] as Color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomIconWidget(
                          iconName:
                              conversation['platform'].toString().toLowerCase(),
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'ตอบกลับ ${conversation['senderName']}',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  // Quick reply suggestions
                  Text('คำตอบแนะนำ:',
                      style: AppTheme.lightTheme.textTheme.labelMedium),
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 2.w,
                    children: [
                      'ขอบคุณสำหรับข้อความ',
                      'จะตอบกลับเร็วๆ นี้',
                      'สนใจข้อมูลเพิ่มเติม',
                    ].map((reply) {
                      return ActionChip(
                        label: Text(reply),
                        onPressed: () {
                          Navigator.pop(context);
                          _sendQuickReply(conversation, reply);
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 2.h),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'พิมพ์ข้อความ...',
                      suffixIcon: IconButton(
                        icon: CustomIconWidget(
                          iconName: 'send',
                          size: 20,
                          color: AppTheme.lightTheme.primaryColor,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _openConversationDetail(conversation);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendQuickReply(Map<String, dynamic> conversation, String message) {
    // Update conversation with quick reply
    setState(() {
      conversation['lastMessage'] = message;
      conversation['timestamp'] = DateTime.now();
      conversation['isRead'] = true;
    });

    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('ส่งข้อความแล้ว')),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> conversation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ลบการสนทนา'),
        content: Text(
            'คุณแน่ใจหรือไม่ที่จะลบการสนทนากับ ${conversation['senderName']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _conversations.remove(conversation);
              });
              Navigator.pop(context);
              HapticFeedback.mediumImpact();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFDC2626),
            ),
            child: Text('ลบ'),
          ),
        ],
      ),
    );
  }

  void _showComposeMessageSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: 60.h,
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
                  Text(
                    'ข้อความใหม่',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'เลือกแพลตฟอร์ม'),
                    items: ['Instagram', 'Facebook', 'Twitter', 'LinkedIn']
                        .map((platform) => DropdownMenuItem(
                              value: platform,
                              child: Text(platform),
                            ))
                        .toList(),
                    onChanged: (value) {},
                  ),
                  SizedBox(height: 2.h),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'ผู้รับ',
                      hintText: 'ค้นหาหรือป้อนชื่อผู้ใช้',
                    ),
                  ),
                  SizedBox(height: 2.h),
                  TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'ข้อความ',
                      hintText: 'พิมพ์ข้อความของคุณ...',
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('ยกเลิก'),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('ส่ง'),
                        ),
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

  void _showBulkActionSheet() {
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
                iconName: 'mark_email_read',
                size: 24,
                color: AppTheme.lightTheme.primaryColor,
              ),
              title: Text('ทำเครื่องหมายทั้งหมดว่าอ่านแล้ว'),
              onTap: () {
                _markAllAsRead();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'archive',
                size: 24,
                color: Color(0xFFD97706),
              ),
              title: Text('เก็บถาวรข้อความที่อ่านแล้ว'),
              onTap: () {
                _archiveReadMessages();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete_sweep',
                size: 24,
                color: Color(0xFFDC2626),
              ),
              title: Text('ลบข้อความเก่า (30 วันขึ้นไป)'),
              onTap: () {
                _deleteOldMessages();
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (var conversation in _conversations) {
        conversation['isRead'] = true;
        conversation['unreadCount'] = 0;
      }
    });
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('ทำเครื่องหมายทั้งหมดว่าอ่านแล้ว')),
    );
  }

  void _archiveReadMessages() {
    final readMessages = _conversations.where((c) => c['isRead']).toList();
    setState(() {
      _conversations.removeWhere((c) => c['isRead']);
    });

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('เก็บถาวร ${readMessages.length} ข้อความแล้ว'),
        action: SnackBarAction(
          label: 'เลิกทำ',
          onPressed: () {
            setState(() {
              _conversations.addAll(readMessages);
            });
          },
        ),
      ),
    );
  }

  void _deleteOldMessages() {
    final cutoffDate = DateTime.now().subtract(Duration(days: 30));
    final oldMessages = _conversations
        .where((c) => (c['timestamp'] as DateTime).isBefore(cutoffDate))
        .toList();

    if (oldMessages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่พบข้อความเก่ากว่า 30 วัน')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ลบข้อความเก่า'),
        content: Text(
            'พบข้อความเก่ากว่า 30 วัน จำนวน ${oldMessages.length} รายการ คุณต้องการลบหรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _conversations.removeWhere((c) => oldMessages.contains(c));
              });
              Navigator.pop(context);
              HapticFeedback.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('ลบข้อความเก่า ${oldMessages.length} รายการแล้ว')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFDC2626)),
            child: Text('ลบ'),
          ),
        ],
      ),
    );
  }
}

// Simple conversation detail screen
class _ConversationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> conversation;

  const _ConversationDetailScreen({
    required this.conversation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipOval(
              child: CustomImageWidget(
                imageUrl: conversation['senderAvatar'] as String,
                width: 32,
                height: 32,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 2.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation['senderName'] as String,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  conversation['platform'] as String,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.getTextColor(context, secondary: true),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (conversation['isOnline'])
            Padding(
              padding: EdgeInsets.only(right: 2.w),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text('รายละเอียดการสนทนาจะแสดงที่นี่'),
            ),
          ),
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: AppTheme.getBorderColor(context),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: CustomIconWidget(
                    iconName: 'attach_file',
                    size: 24,
                    color: AppTheme.getTextColor(context, secondary: true),
                  ),
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'พิมพ์ข้อความ...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                IconButton(
                  onPressed: () {},
                  icon: CustomIconWidget(
                    iconName: 'send',
                    size: 24,
                    color: AppTheme.lightTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
