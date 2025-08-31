import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/connected_accounts_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/team_members_widget.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _autoPostEnabled = false;
  String _selectedLanguage = "ไทย";

  // Mock user profile data
  final Map<String, dynamic> userProfile = {
    "id": 1,
    "name": "สมชาย วงศ์สุวรรณ",
    "email": "somchai.w@example.com",
    "avatar":
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face",
    "tier": "Pro Plan",
    "joinDate": "มกราคม 2024",
  };

  // Mock connected accounts data
  final List<Map<String, dynamic>> connectedAccounts = [
    {
      "id": 1,
      "platform": "Facebook",
      "username": "@somchai.business",
      "isConnected": true,
      "logo":
          "https://upload.wikimedia.org/wikipedia/commons/5/51/Facebook_f_logo_%282019%29.svg",
      "color": const Color(0xFF1877F2),
      "followers": "12.5K",
    },
    {
      "id": 2,
      "platform": "Instagram",
      "username": "@somchai_official",
      "isConnected": true,
      "logo":
          "https://upload.wikimedia.org/wikipedia/commons/a/a5/Instagram_icon.png",
      "color": const Color(0xFFE4405F),
      "followers": "8.2K",
    },
    {
      "id": 3,
      "platform": "Twitter",
      "username": "",
      "isConnected": false,
      "logo":
          "https://upload.wikimedia.org/wikipedia/commons/6/6f/Logo_of_Twitter.svg",
      "color": const Color(0xFF1DA1F2),
      "followers": "0",
    },
    {
      "id": 4,
      "platform": "LinkedIn",
      "username": "somchai-wong",
      "isConnected": true,
      "logo":
          "https://upload.wikimedia.org/wikipedia/commons/c/ca/LinkedIn_logo_initials.png",
      "color": const Color(0xFF0A66C2),
      "followers": "1.8K",
    },
  ];

  // Mock team members data
  final List<Map<String, dynamic>> teamMembers = [
    {
      "id": 1,
      "name": "สุดา ใจดี",
      "email": "suda.j@example.com",
      "avatar":
          "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face",
      "role": "Admin",
      "joinDate": "กุมภาพันธ์ 2024",
    },
    {
      "id": 2,
      "name": "วิชัย รักงาน",
      "email": "wichai.r@example.com",
      "avatar":
          "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face",
      "role": "Editor",
      "joinDate": "มีนาคม 2024",
    },
    {
      "id": 3,
      "name": "มาลี สวยงาม",
      "email": "malee.s@example.com",
      "avatar":
          "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face",
      "role": "Viewer",
      "joinDate": "เมษายน 2024",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
      appBar: AppBar(
        title: Text(
          "โปรไฟล์",
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        actions: [
          IconButton(
            onPressed: _showSettingsMenu,
            icon: CustomIconWidget(
              iconName: 'more_vert',
              color: AppTheme.getTextColor(context),
              size: 6.w,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "ภาพรวม"),
            Tab(text: "บัญชี"),
            Tab(text: "ทีม"),
            Tab(text: "การตั้งค่า"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildAccountsTab(),
          _buildTeamTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          ProfileHeaderWidget(userProfile: userProfile),
          SizedBox(height: 2.h),
          _buildStatsCards(),
          SizedBox(height: 2.h),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildAccountsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          ConnectedAccountsWidget(
            connectedAccounts: connectedAccounts,
            onAccountTap: _handleAccountTap,
          ),
          SettingsSectionWidget(
            title: "การจัดการบัญชี",
            items: [
              {
                "key": "edit_profile",
                "title": "แก้ไขโปรไฟล์",
                "subtitle": "เปลี่ยนชื่อ อีเมล และรูปโปรไฟล์",
                "icon": "person",
                "iconColor": AppTheme.lightTheme.primaryColor,
                "type": "navigation",
              },
              {
                "key": "change_password",
                "title": "เปลี่ยนรหัสผ่าน",
                "subtitle": "อัปเดตรหัสผ่านเพื่อความปลอดภัย",
                "icon": "lock",
                "iconColor": AppTheme.lightTheme.colorScheme.tertiary,
                "type": "navigation",
              },
              {
                "key": "subscription",
                "title": "การสมัครสมาชิก",
                "subtitle": "Pro Plan - หมดอายุ 31 ธ.ค. 2024",
                "icon": "star",
                "iconColor": const Color(0xFFFFB800),
                "type": "navigation",
              },
            ],
            onItemTap: _handleSettingsTap,
          ),
        ],
      ),
    );
  }

  Widget _buildTeamTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          TeamMembersWidget(
            teamMembers: teamMembers,
            onMemberTap: _handleMemberTap,
          ),
          SettingsSectionWidget(
            title: "การจัดการทีม",
            items: [
              {
                "key": "team_roles",
                "title": "จัดการบทบาท",
                "subtitle": "กำหนดสิทธิ์การเข้าถึงสำหรับสมาชิก",
                "icon": "admin_panel_settings",
                "iconColor": AppTheme.lightTheme.colorScheme.error,
                "type": "navigation",
              },
              {
                "key": "team_analytics",
                "title": "รายงานทีม",
                "subtitle": "ดูประสิทธิภาพการทำงานของทีม",
                "icon": "analytics",
                "iconColor": AppTheme.lightTheme.primaryColor,
                "type": "navigation",
              },
            ],
            onItemTap: _handleSettingsTap,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          SettingsSectionWidget(
            title: "การตั้งค่าแอป",
            items: [
              {
                "key": "dark_mode",
                "title": "โหมดมืด",
                "subtitle": "เปลี่ยนธีมของแอปพลิเคชัน",
                "icon": "dark_mode",
                "iconColor": AppTheme.lightTheme.colorScheme.secondary,
                "type": "switch",
                "value": _isDarkMode,
              },
              {
                "key": "notifications",
                "title": "การแจ้งเตือน",
                "subtitle": "รับการแจ้งเตือนเมื่อมีกิจกรรมใหม่",
                "icon": "notifications",
                "iconColor": AppTheme.lightTheme.colorScheme.tertiary,
                "type": "switch",
                "value": _notificationsEnabled,
              },
              {
                "key": "auto_post",
                "title": "โพสต์อัตโนมัติ",
                "subtitle": "เปิดใช้งานการโพสต์ตามกำหนดเวลา",
                "icon": "schedule",
                "iconColor": AppTheme.lightTheme.primaryColor,
                "type": "switch",
                "value": _autoPostEnabled,
              },
              {
                "key": "language",
                "title": "ภาษา",
                "subtitle": _selectedLanguage,
                "icon": "language",
                "iconColor": const Color(0xFF9C27B0),
                "type": "navigation",
              },
            ],
            onItemTap: _handleSettingsTap,
          ),
          SettingsSectionWidget(
            title: "รายงานและการวิเคราะห์",
            items: [
              {
                "key": "analytics",
                "title": "รายงานประสิทธิภาพ",
                "subtitle": "ดูสถิติการมีส่วนร่วมและการเข้าถึง",
                "icon": "bar_chart",
                "iconColor": AppTheme.lightTheme.primaryColor,
                "type": "navigation",
              },
              {
                "key": "export_data",
                "title": "ส่งออกข้อมูล",
                "subtitle": "ดาวน์โหลดรายงานในรูปแบบ CSV หรือ PDF",
                "icon": "download",
                "iconColor": AppTheme.lightTheme.colorScheme.tertiary,
                "type": "navigation",
              },
            ],
            onItemTap: _handleSettingsTap,
          ),
          SettingsSectionWidget(
            title: "ความช่วยเหลือและการสนับสนุน",
            items: [
              {
                "key": "faq",
                "title": "คำถามที่พบบ่อย",
                "subtitle": "หาคำตอบสำหรับคำถามทั่วไป",
                "icon": "help",
                "iconColor": AppTheme.lightTheme.colorScheme.tertiary,
                "type": "navigation",
              },
              {
                "key": "contact_support",
                "title": "ติดต่อฝ่ายสนับสนุน",
                "subtitle": "ส่งข้อความหาทีมสนับสนุน",
                "icon": "support_agent",
                "iconColor": AppTheme.lightTheme.primaryColor,
                "type": "navigation",
              },
              {
                "key": "app_version",
                "title": "เวอร์ชันแอป",
                "subtitle": "v2.1.0 (Build 210)",
                "icon": "info",
                "iconColor": AppTheme.lightTheme.colorScheme.secondary,
                "type": "navigation",
              },
            ],
            onItemTap: _handleSettingsTap,
          ),
          SizedBox(height: 2.h),
          _buildLogoutButton(),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final List<Map<String, dynamic>> stats = [
      {
        "title": "โพสต์ทั้งหมด",
        "value": "247",
        "icon": "post_add",
        "color": AppTheme.lightTheme.primaryColor,
        "change": "+12%",
      },
      {
        "title": "ผู้ติดตาม",
        "value": "22.5K",
        "icon": "people",
        "color": AppTheme.lightTheme.colorScheme.tertiary,
        "change": "+8%",
      },
      {
        "title": "การมีส่วนร่วม",
        "value": "4.2K",
        "icon": "favorite",
        "color": const Color(0xFFE91E63),
        "change": "+15%",
      },
      {
        "title": "การเข้าถึง",
        "value": "156K",
        "icon": "visibility",
        "color": const Color(0xFFFF9800),
        "change": "+22%",
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 2.h,
        childAspectRatio: 1.5,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
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
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: (stat["color"] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: stat["icon"] as String,
                      color: stat["color"] as Color,
                      size: 5.w,
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.tertiary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      stat["change"] as String,
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.tertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                stat["value"] as String,
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                stat["title"] as String,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.getTextColor(context, secondary: true),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    final List<Map<String, dynamic>> actions = [
      {
        "title": "สร้างโพสต์",
        "icon": "add",
        "color": AppTheme.lightTheme.primaryColor,
        "route": "/post-creation",
      },
      {
        "title": "ปฏิทินเนื้อหา",
        "icon": "calendar_today",
        "color": AppTheme.lightTheme.colorScheme.tertiary,
        "route": "/content-calendar",
      },
      {
        "title": "รายงาน",
        "icon": "analytics",
        "color": const Color(0xFFFF9800),
        "route": "/analytics",
      },
      {
        "title": "การตั้งค่า",
        "icon": "settings",
        "color": AppTheme.lightTheme.colorScheme.secondary,
        "route": "/settings",
      },
    ];

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "การดำเนินการด่วน",
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 2.h,
              childAspectRatio: 2.5,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return InkWell(
                onTap: () => _handleQuickAction(action["route"] as String),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: (action["color"] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (action["color"] as Color).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: action["icon"] as String,
                        color: action["color"] as Color,
                        size: 5.w,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          action["title"] as String,
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: action["color"] as Color,
                            fontWeight: FontWeight.w500,
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
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _showLogoutDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 3.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'logout',
              color: Colors.white,
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Text(
              "ออกจากระบบ",
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAccountTap(String action) {
    if (action == "add_account") {
      _showAddAccountDialog();
    } else {
      _showAccountDetailsDialog(action);
    }
  }

  void _handleMemberTap(String memberId) {
    if (memberId == "invite_member") {
      _showInviteMemberDialog();
    } else {
      _showMemberDetailsDialog(memberId);
    }
  }

  void _handleSettingsTap(String key, dynamic value) {
    switch (key) {
      case "dark_mode":
        setState(() => _isDarkMode = value as bool);
        break;
      case "notifications":
        setState(() => _notificationsEnabled = value as bool);
        break;
      case "auto_post":
        setState(() => _autoPostEnabled = value as bool);
        break;
      case "language":
        _showLanguageDialog();
        break;
      case "edit_profile":
        _showEditProfileDialog();
        break;
      case "change_password":
        _showChangePasswordDialog();
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("เปิดหน้า: $key"),
            duration: const Duration(seconds: 2),
          ),
        );
    }
  }

  void _handleQuickAction(String route) {
    if (route == "/post-creation" || route == "/content-calendar") {
      Navigator.pushNamed(context, route);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("เปิดหน้า: $route"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'edit',
                color: AppTheme.lightTheme.primaryColor,
                size: 6.w,
              ),
              title: const Text("แก้ไขโปรไฟล์"),
              onTap: () {
                Navigator.pop(context);
                _showEditProfileDialog();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: AppTheme.lightTheme.colorScheme.tertiary,
                size: 6.w,
              ),
              title: const Text("แชร์โปรไฟล์"),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("แชร์โปรไฟล์")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("ออกจากระบบ"),
        content: const Text("คุณแน่ใจหรือไม่ว่าต้องการออกจากระบบ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ยกเลิก"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login-screen',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: const Text("ออกจากระบบ"),
          ),
        ],
      ),
    );
  }

  void _showAddAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("เพิ่มบัญชีโซเชียลมีเดีย"),
        content: const Text("เลือกแพลตฟอร์มที่ต้องการเชื่อมต่อ"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ยกเลิก"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("เชื่อมต่อบัญชีใหม่")),
              );
            },
            child: const Text("เชื่อมต่อ"),
          ),
        ],
      ),
    );
  }

  void _showAccountDetailsDialog(String platform) {
    final account = connectedAccounts.firstWhere(
      (acc) => acc["platform"] == platform,
      orElse: () => <String, dynamic>{},
    );

    if (account.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("บัญชี ${account["platform"]}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ชื่อผู้ใช้: ${account["username"]}"),
            Text("ผู้ติดตาม: ${account["followers"]}"),
            Text(
                "สถานะ: ${account["isConnected"] ? "เชื่อมต่อแล้ว" : "ไม่ได้เชื่อมต่อ"}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ปิด"),
          ),
          if (account["isConnected"] as bool)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text("ยกเลิกการเชื่อมต่อ ${account["platform"]}")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.error,
              ),
              child: const Text("ยกเลิกการเชื่อมต่อ"),
            ),
        ],
      ),
    );
  }

  void _showInviteMemberDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("เชิญสมาชิกใหม่"),
        content: const TextField(
          decoration: InputDecoration(
            labelText: "อีเมลของสมาชิก",
            hintText: "example@email.com",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ยกเลิก"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("ส่งคำเชิญแล้ว")),
              );
            },
            child: const Text("ส่งคำเชิญ"),
          ),
        ],
      ),
    );
  }

  void _showMemberDetailsDialog(String memberId) {
    final member = teamMembers.firstWhere(
      (m) => m["id"].toString() == memberId,
      orElse: () => <String, dynamic>{},
    );

    if (member.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("สมาชิก: ${member["name"]}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("อีเมล: ${member["email"]}"),
            Text("บทบาท: ${member["role"]}"),
            Text("เข้าร่วมเมื่อ: ${member["joinDate"]}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ปิด"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("แก้ไขสมาชิก: ${member["name"]}")),
              );
            },
            child: const Text("แก้ไข"),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("แก้ไขโปรไฟล์"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: "ชื่อ"),
              controller:
                  TextEditingController(text: userProfile["name"] as String),
            ),
            SizedBox(height: 2.h),
            TextField(
              decoration: const InputDecoration(labelText: "อีเมล"),
              controller:
                  TextEditingController(text: userProfile["email"] as String),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ยกเลิก"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("บันทึกการเปลี่ยนแปลงแล้ว")),
              );
            },
            child: const Text("บันทึก"),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("เปลี่ยนรหัสผ่าน"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(labelText: "รหัสผ่านปัจจุบัน"),
              obscureText: true,
            ),
            SizedBox(height: 2.h),
            const TextField(
              decoration: InputDecoration(labelText: "รหัสผ่านใหม่"),
              obscureText: true,
            ),
            SizedBox(height: 2.h),
            const TextField(
              decoration: InputDecoration(labelText: "ยืนยันรหัสผ่านใหม่"),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ยกเลิก"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("เปลี่ยนรหัสผ่านสำเร็จ")),
              );
            },
            child: const Text("เปลี่ยนรหัสผ่าน"),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    final languages = ["ไทย", "English", "中文", "日本語"];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("เลือกภาษา"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages
              .map((lang) => RadioListTile<String>(
                    title: Text(lang),
                    value: lang,
                    groupValue: _selectedLanguage,
                    onChanged: (value) {
                      setState(() => _selectedLanguage = value!);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("เปลี่ยนภาษาเป็น: $value")),
                      );
                    },
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ยกเลิก"),
          ),
        ],
      ),
    );
  }
}
