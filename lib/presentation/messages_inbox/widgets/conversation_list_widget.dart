import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ConversationListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> conversations;
  final Function(Map<String, dynamic>) onConversationTap;
  final Function(Map<String, dynamic>, String) onConversationSwipe;
  final Function(Map<String, dynamic>) onQuickReply;
  final Function(Map<String, dynamic>) onMarkAsRead;
  final Function(Map<String, dynamic>) onArchive;
  final Function(Map<String, dynamic>) onDelete;

  const ConversationListWidget({
    Key? key,
    required this.conversations,
    required this.onConversationTap,
    required this.onConversationSwipe,
    required this.onQuickReply,
    required this.onMarkAsRead,
    required this.onArchive,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (conversations.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      itemCount: conversations.length,
      separatorBuilder: (context, index) => SizedBox(height: 1.h),
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return _buildConversationItem(context, conversation);
      },
    );
  }

  Widget _buildConversationItem(
      BuildContext context, Map<String, dynamic> conversation) {
    return Dismissible(
      key: Key(conversation['id'].toString()),
      background: _buildSwipeBackground(context, isLeftSwipe: false),
      secondaryBackground: _buildSwipeBackground(context, isLeftSwipe: true),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          onConversationSwipe(conversation, 'reply');
        } else {
          onConversationSwipe(conversation, 'archive');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: conversation['isRead']
              ? AppTheme.lightTheme.colorScheme.surface
              : AppTheme.lightTheme.primaryColor.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: conversation['isRead']
                ? AppTheme.getBorderColor(context)
                : AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onConversationTap(conversation),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  Stack(
                    children: [
                      ClipOval(
                        child: CustomImageWidget(
                          imageUrl: conversation['senderAvatar'] as String,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (conversation['isOnline'] == true)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.lightTheme.colorScheme.surface,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: conversation['platformColor'] as Color,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: CustomIconWidget(
                                iconName: conversation['platform']
                                    .toString()
                                    .toLowerCase(),
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                conversation['senderName'] as String,
                                style: AppTheme.lightTheme.textTheme.titleSmall
                                    ?.copyWith(
                                  fontWeight: conversation['isRead']
                                      ? FontWeight.w500
                                      : FontWeight.w600,
                                  color: AppTheme.getTextColor(context),
                                ),
                              ),
                            ),
                            if (conversation['isPriority'] == true)
                              Container(
                                margin: EdgeInsets.only(left: 1.w),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 1.5.w, vertical: 0.5.h),
                                decoration: BoxDecoration(
                                  color: Color(0xFFDC2626),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'สำคัญ',
                                  style: AppTheme
                                      .lightTheme.textTheme.labelSmall
                                      ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            Text(
                              _formatTime(
                                  conversation['timestamp'] as DateTime),
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.getTextColor(context,
                                    secondary: true),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        Row(
                          children: [
                            if (conversation['messageType'] == 'image')
                              Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'image',
                                    size: 16,
                                    color: AppTheme.getTextColor(context,
                                        secondary: true),
                                  ),
                                  SizedBox(width: 1.w),
                                ],
                              )
                            else if (conversation['messageType'] == 'document')
                              Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'attach_file',
                                    size: 16,
                                    color: AppTheme.getTextColor(context,
                                        secondary: true),
                                  ),
                                  SizedBox(width: 1.w),
                                ],
                              ),
                            Expanded(
                              child: Text(
                                conversation['lastMessage'] as String,
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: conversation['isRead']
                                      ? AppTheme.getTextColor(context,
                                          secondary: true)
                                      : AppTheme.getTextColor(context),
                                  fontWeight: conversation['isRead']
                                      ? FontWeight.w400
                                      : FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      if (conversation['unreadCount'] > 0)
                        Container(
                          padding: EdgeInsets.all(1.w),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${conversation['unreadCount']}',
                            style: AppTheme.lightTheme.textTheme.labelSmall
                                ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      SizedBox(height: 2.h),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'reply':
                              onQuickReply(conversation);
                              break;
                            case 'markRead':
                              onMarkAsRead(conversation);
                              break;
                            case 'archive':
                              onArchive(conversation);
                              break;
                            case 'delete':
                              onDelete(conversation);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'reply',
                            child: Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'reply',
                                  size: 20,
                                  color: AppTheme.lightTheme.primaryColor,
                                ),
                                SizedBox(width: 2.w),
                                Text('ตอบกลับด่วน'),
                              ],
                            ),
                          ),
                          if (!conversation['isRead'])
                            PopupMenuItem(
                              value: 'markRead',
                              child: Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'mark_email_read',
                                    size: 20,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text('ทำเครื่องหมายว่าอ่านแล้ว'),
                                ],
                              ),
                            ),
                          PopupMenuItem(
                            value: 'archive',
                            child: Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'archive',
                                  size: 20,
                                  color: Color(0xFFD97706),
                                ),
                                SizedBox(width: 2.w),
                                Text('เก็บถาวร'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'delete',
                                  size: 20,
                                  color: Color(0xFFDC2626),
                                ),
                                SizedBox(width: 2.w),
                                Text('ลบ'),
                              ],
                            ),
                          ),
                        ],
                        child: CustomIconWidget(
                          iconName: 'more_vert',
                          size: 20,
                          color:
                              AppTheme.getTextColor(context, secondary: true),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(BuildContext context,
      {required bool isLeftSwipe}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.5.h),
      decoration: BoxDecoration(
        color:
            isLeftSwipe ? Color(0xFFD97706) : AppTheme.lightTheme.primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Row(
          mainAxisAlignment:
              isLeftSwipe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            CustomIconWidget(
              iconName: isLeftSwipe ? 'archive' : 'reply',
              color: Colors.white,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              isLeftSwipe ? 'เก็บถาวร' : 'ตอบกลับ',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.getBorderColor(context).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: CustomIconWidget(
              iconName: 'message',
              color: AppTheme.getTextColor(context, secondary: true),
              size: 50,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'ไม่มีข้อความใหม่',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'ข้อความจากโซเชียลมีเดียจะแสดงที่นี่',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.getTextColor(context, secondary: true),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} นาที';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ชั่วโมง';
    } else if (difference.inDays == 1) {
      return 'เมื่อวาน';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} วัน';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}
