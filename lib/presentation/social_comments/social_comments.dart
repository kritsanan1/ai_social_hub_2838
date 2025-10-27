import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/app_layout.dart';
import '../../theme/app_theme.dart';

/// Social Comments Screen
/// 
/// Manage comments across all social media platforms
class SocialComments extends ConsumerStatefulWidget {
  const SocialComments({Key? key}) : super(key: key);

  @override
  ConsumerState<SocialComments> createState() => _SocialCommentsState();
}

class _SocialCommentsState extends ConsumerState<SocialComments>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _platforms = ['All', 'Facebook', 'Instagram', 'Twitter', 'LinkedIn'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _platforms.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Social Comments',
      child: Column(
        children: [
          // Platform Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppTheme.lightTheme.colorScheme.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppTheme.lightTheme.colorScheme.primary,
              tabs: _platforms.map((platform) => Tab(text: platform)).toList(),
            ),
          ),

          // Comments List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _platforms.map((platform) {
                return _buildCommentsList(platform);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList(String platform) {
    // Mock data - will be replaced with real data from Ayrshare API
    final mockComments = [
      {
        'post': 'Check out our new product launch! 🚀',
        'comment': 'This looks amazing! When will it be available?',
        'author': 'John Doe',
        'platform': 'Facebook',
        'time': '2 hours ago',
        'avatar': null,
      },
      {
        'post': 'Behind the scenes of our latest campaign',
        'comment': 'Love the creativity! 💡',
        'author': 'Jane Smith',
        'platform': 'Instagram',
        'time': '5 hours ago',
        'avatar': null,
      },
      {
        'post': 'Excited to announce our partnership with...',
        'comment': 'Congratulations! This is huge!',
        'author': 'Mike Johnson',
        'platform': 'LinkedIn',
        'time': '1 day ago',
        'avatar': null,
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: mockComments.length,
      itemBuilder: (context, index) {
        final comment = mockComments[index];
        return _buildCommentCard(comment);
      },
    );
  }

  Widget _buildCommentCard(Map<String, dynamic> comment) {
    return Card(
      margin: EdgeInsets.only(bottom: 3.w),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Original Post
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      comment['post'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Comment
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
                  child: Text(
                    (comment['author'] as String)[0],
                    style: TextStyle(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            comment['author'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getPlatformColor(comment['platform'] as String).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              comment['platform'] as String,
                              style: TextStyle(
                                fontSize: 10,
                                color: _getPlatformColor(comment['platform'] as String),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        comment['comment'] as String,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        comment['time'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Actions
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    _showReplyDialog(context, comment);
                  },
                  icon: const Icon(Icons.reply, size: 18),
                  label: const Text('Reply'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite_border, size: 18),
                  label: const Text('Like'),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'instagram':
        return const Color(0xFFE4405F);
      case 'twitter':
        return const Color(0xFF1DA1F2);
      case 'linkedin':
        return const Color(0xFF0A66C2);
      default:
        return Colors.grey;
    }
  }

  void _showReplyDialog(BuildContext context, Map<String, dynamic> comment) {
    final replyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reply to Comment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Replying to ${comment['author']}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: replyController,
              decoration: const InputDecoration(
                hintText: 'Type your reply...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Send reply via Ayrshare API
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reply sent!')),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}

