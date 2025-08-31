import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/calendar_grid_widget.dart';
import './widgets/calendar_header_widget.dart';
import './widgets/day_detail_sheet_widget.dart';
import './widgets/day_view_widget.dart';
import './widgets/week_view_widget.dart';

class ContentCalendar extends StatefulWidget {
  const ContentCalendar({Key? key}) : super(key: key);

  @override
  State<ContentCalendar> createState() => _ContentCalendarState();
}

class _ContentCalendarState extends State<ContentCalendar>
    with TickerProviderStateMixin {
  String _selectedView = 'Month';
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isRefreshing = false;

  late TabController _tabController;

  // Mock data for scheduled posts
  final List<Map<String, dynamic>> _scheduledPosts = [
    {
      "id": 1,
      "content":
          "เปิดตัวผลิตภัณฑ์ใหม่ล่าสุดของเรา! 🚀 พร้อมด้วยฟีเจอร์ที่น่าตื่นเต้นมากมาย",
      "scheduledDate": "2025-01-15T09:00:00.000Z",
      "platforms": ["Facebook", "Instagram"],
      "status": "scheduled",
      "imageUrl":
          "https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "author": "Marketing Team"
    },
    {
      "id": 2,
      "content":
          "Tips การใช้งาน AI ในการจัดการโซเชียลมีเดียให้มีประสิทธิภาพมากขึ้น 💡",
      "scheduledDate": "2025-01-15T14:30:00.000Z",
      "platforms": ["Twitter", "LinkedIn"],
      "status": "scheduled",
      "imageUrl":
          "https://images.unsplash.com/photo-1677442136019-21780ecad995?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "author": "Content Team"
    },
    {
      "id": 3,
      "content": "Behind the scenes ของทีมพัฒนาแอป AI Social Hub 🎬",
      "scheduledDate": "2025-01-16T11:00:00.000Z",
      "platforms": ["Instagram", "TikTok"],
      "status": "scheduled",
      "imageUrl":
          "https://images.unsplash.com/photo-1522202176988-66273c2fd55f?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "author": "Dev Team"
    },
    {
      "id": 4,
      "content":
          "Customer Success Story: บริษัท ABC เพิ่มยอดขายได้ 300% ด้วย AI Social Hub! 📈",
      "scheduledDate": "2025-01-17T16:00:00.000Z",
      "platforms": ["Facebook", "LinkedIn"],
      "status": "scheduled",
      "imageUrl":
          "https://images.unsplash.com/photo-1460925895917-afdab827c52f?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "author": "Sales Team"
    },
    {
      "id": 5,
      "content": "Weekly Analytics Report: สถิติการมีส่วนร่วมของสัปดาห์นี้ 📊",
      "scheduledDate": "2025-01-18T10:00:00.000Z",
      "platforms": ["Twitter"],
      "status": "draft",
      "author": "Analytics Team"
    },
    {
      "id": 6,
      "content": "Live Q&A Session เกี่ยวกับการใช้ AI ในการสร้างคอนเทนต์ 🎥",
      "scheduledDate": "2025-01-19T19:00:00.000Z",
      "platforms": ["Facebook", "YouTube"],
      "status": "scheduled",
      "imageUrl":
          "https://images.unsplash.com/photo-1611224923853-80b023f02d71?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "author": "Community Team"
    },
    {
      "id": 7,
      "content":
          "Weekend Motivation: เคล็ดลับการสร้างแบรนด์ที่แข็งแกร่งในยุคดิจิทัล 💪",
      "scheduledDate": "2025-01-20T08:00:00.000Z",
      "platforms": ["Instagram", "LinkedIn"],
      "status": "published",
      "imageUrl":
          "https://images.unsplash.com/photo-1552664730-d307ca884978?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "author": "Brand Team"
    },
    {
      "id": 8,
      "content":
          "New Feature Alert: ตอนนี้สามารถกำหนดเวลาโพสต์ล่วงหน้าได้ถึง 6 เดือน! ⏰",
      "scheduledDate": "2025-01-21T13:15:00.000Z",
      "platforms": ["Facebook", "Twitter", "Instagram"],
      "status": "scheduled",
      "imageUrl":
          "https://images.unsplash.com/photo-1611224923853-80b023f02d71?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "author": "Product Team"
    }
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _tabController = TabController(length: 4, vsync: this, initialIndex: 1);
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
      body: Column(
        children: [
          CalendarHeaderWidget(
            selectedView: _selectedView,
            onViewChanged: _onViewChanged,
            onTodayPressed: _onTodayPressed,
            currentDate: _focusedDay,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              color: AppTheme.lightTheme.primaryColor,
              child: _buildCalendarView(),
            ),
          ),
        ],
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
      title: Text(
        'ปฏิทินคอนเทนต์',
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          color: AppTheme.getTextColor(context),
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          size: 24,
          color: AppTheme.getTextColor(context),
        ),
      ),
      actions: [
        IconButton(
          onPressed: _onSearchPressed,
          icon: CustomIconWidget(
            iconName: 'search',
            size: 24,
            color: AppTheme.getTextColor(context),
          ),
        ),
        IconButton(
          onPressed: _onFilterPressed,
          icon: CustomIconWidget(
            iconName: 'filter_list',
            size: 24,
            color: AppTheme.getTextColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarView() {
    switch (_selectedView) {
      case 'Week':
        return WeekViewWidget(
          currentWeek: _focusedDay,
          selectedDay: _selectedDay,
          onDaySelected: (DateTime selectedDay) => _onDaySelected(selectedDay, selectedDay),
          scheduledPosts: _scheduledPosts,
          onDayLongPress: _onDayLongPress,
        );
      case 'Day':
        return DayViewWidget(
          selectedDay: _selectedDay ?? _focusedDay,
          scheduledPosts: _scheduledPosts,
          onPostTap: _onPostTap,
          onPostLongPress: _onPostLongPress,
        );
      default:
        return CalendarGridWidget(
          focusedDay: _focusedDay,
          selectedDay: _selectedDay,
          onDaySelected: _onDaySelected,
          onPageChanged: _onPageChanged,
          scheduledPosts: _scheduledPosts,
          onDayLongPress: _onDayLongPress,
        );
    }
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

  void _onViewChanged(String view) {
    setState(() {
      _selectedView = view;
    });
    HapticFeedback.selectionClick();
  }

  void _onTodayPressed() {
    setState(() {
      _focusedDay = DateTime.now();
      _selectedDay = DateTime.now();
    });
    HapticFeedback.lightImpact();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    final dayPosts = _getPostsForDay(selectedDay);
    if (dayPosts.isNotEmpty) {
      _showDayDetailSheet(selectedDay, dayPosts);
    }

    HapticFeedback.selectionClick();
  }

  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });
  }

  void _onDayLongPress(DateTime day) {
    HapticFeedback.mediumImpact();
    _showDayDetailSheet(day, _getPostsForDay(day));
  }

  void _onPostTap(Map<String, dynamic> post) {
    HapticFeedback.lightImpact();
    _showPostDetailDialog(post);
  }

  void _onPostLongPress(Map<String, dynamic> post) {
    HapticFeedback.mediumImpact();
    _showPostOptionsSheet(post);
  }

  void _onCreatePost() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/post-creation');
  }

  void _onSearchPressed() {
    HapticFeedback.lightImpact();
    _showSearchDialog();
  }

  void _onFilterPressed() {
    HapticFeedback.lightImpact();
    _showFilterSheet();
  }

  void _onTabChanged(int index) {
    HapticFeedback.selectionClick();
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      case 1:
        // Current screen
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/messages');
        break;
      case 3:
        Navigator.pushNamed(context, '/user-profile');
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

  List<Map<String, dynamic>> _getPostsForDay(DateTime day) {
    return _scheduledPosts.where((post) {
      final postDate = DateTime.parse(post['scheduledDate'] as String);
      return postDate.day == day.day &&
          postDate.month == day.month &&
          postDate.year == day.year;
    }).toList();
  }

  void _showDayDetailSheet(
      DateTime selectedDate, List<Map<String, dynamic>> posts) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DayDetailSheetWidget(
        selectedDate: selectedDate,
        posts: posts,
        onPostTap: _onPostTap,
        onPostEdit: _onPostEdit,
        onPostDelete: _onPostDelete,
        onCreatePost: _onCreatePost,
      ),
    );
  }

  void _showPostDetailDialog(Map<String, dynamic> post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('รายละเอียดโพสต์'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (post['imageUrl'] != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CustomImageWidget(
                    imageUrl: post['imageUrl'] as String,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 2.h),
              ],
              Text(
                'เนื้อหา:',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              Text(post['content'] as String),
              SizedBox(height: 2.h),
              Text(
                'แพลตฟอร์ม:',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              Wrap(
                spacing: 1.w,
                children: (post['platforms'] as List).map((platform) {
                  return Chip(
                    label: Text(platform as String),
                    backgroundColor:
                        AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                  );
                }).toList(),
              ),
              SizedBox(height: 2.h),
              Text(
                'เวลาที่กำหนด:',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              Text(_formatDateTime(
                  DateTime.parse(post['scheduledDate'] as String))),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ปิด'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _onPostEdit(post);
            },
            child: Text('แก้ไข'),
          ),
        ],
      ),
    );
  }

  void _showPostOptionsSheet(Map<String, dynamic> post) {
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
                iconName: 'edit',
                size: 24,
                color: AppTheme.lightTheme.primaryColor,
              ),
              title: Text('แก้ไข'),
              onTap: () {
                Navigator.pop(context);
                _onPostEdit(post);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'content_copy',
                size: 24,
                color: AppTheme.getTextColor(context),
              ),
              title: Text('ทำสำเนา'),
              onTap: () {
                Navigator.pop(context);
                _onPostDuplicate(post);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'schedule',
                size: 24,
                color: Color(0xFFD97706),
              ),
              title: Text('เปลี่ยนเวลา'),
              onTap: () {
                Navigator.pop(context);
                _onPostReschedule(post);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                size: 24,
                color: Color(0xFFDC2626),
              ),
              title: Text('ลบ'),
              onTap: () {
                Navigator.pop(context);
                _onPostDelete(post);
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ค้นหาโพสต์'),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'ค้นหาด้วยเนื้อหา, แพลตฟอร์ม หรือวันที่...',
            prefixIcon: CustomIconWidget(
              iconName: 'search',
              size: 20,
              color: AppTheme.getTextColor(context, secondary: true),
            ),
          ),
          onChanged: (value) {
            // Handle search
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ค้นหา'),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
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
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                children: [
                  Text(
                    'ตัวกรอง',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: Text('รีเซ็ต'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                children: [
                  Text(
                    'สถานะ',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 2.w,
                    children: [
                      'กำหนดเผยแพร่',
                      'เผยแพร่แล้ว',
                      'แบบร่าง',
                      'ล้มเหลว'
                    ].map((status) {
                      return FilterChip(
                        label: Text(status),
                        selected: false,
                        onSelected: (selected) {},
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'แพลตฟอร์ม',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 2.w,
                    children: [
                      'Facebook',
                      'Instagram',
                      'Twitter',
                      'LinkedIn',
                      'TikTok',
                      'YouTube'
                    ].map((platform) {
                      return FilterChip(
                        label: Text(platform),
                        selected: false,
                        onSelected: (selected) {},
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
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
                      child: Text('ใช้ตัวกรอง'),
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

  void _onPostEdit(Map<String, dynamic> post) {
    Navigator.pushNamed(context, '/post-creation', arguments: post);
  }

  void _onPostDelete(Map<String, dynamic> post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ลบโพสต์'),
        content: Text('คุณแน่ใจหรือไม่ที่จะลบโพสต์นี้?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _scheduledPosts.removeWhere((p) => p['id'] == post['id']);
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

  void _onPostDuplicate(Map<String, dynamic> post) {
    final duplicatedPost = Map<String, dynamic>.from(post);
    duplicatedPost['id'] = _scheduledPosts.length + 1;
    duplicatedPost['content'] = '${post['content']} (สำเนา)';

    setState(() {
      _scheduledPosts.add(duplicatedPost);
    });

    HapticFeedback.lightImpact();
  }

  void _onPostReschedule(Map<String, dynamic> post) {
    showDatePicker(
      context: context,
      initialDate: DateTime.parse(post['scheduledDate'] as String),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    ).then((date) {
      if (date != null) {
        showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(
              DateTime.parse(post['scheduledDate'] as String)),
        ).then((time) {
          if (time != null) {
            final newDateTime = DateTime(
              date.year,
              date.month,
              date.day,
              time.hour,
              time.minute,
            );

            setState(() {
              final index =
                  _scheduledPosts.indexWhere((p) => p['id'] == post['id']);
              if (index != -1) {
                _scheduledPosts[index]['scheduledDate'] =
                    newDateTime.toIso8601String();
              }
            });

            HapticFeedback.lightImpact();
          }
        });
      }
    });
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'มกราคม',
      'กุมภาพันธ์',
      'มีนาคม',
      'เมษายน',
      'พฤษภาคม',
      'มิถุนายน',
      'กรกฎาคม',
      'สิงหาคม',
      'กันยายน',
      'ตุลาคม',
      'พฤศจิกายน',
      'ธันวาคม'
    ];

    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year + 543} เวลา ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} น.';
  }
}