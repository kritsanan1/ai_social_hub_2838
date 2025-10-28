/// Ayrshare API Integration Example
/// 
/// This file demonstrates how to use Ayrshare API in the app
/// 
/// Run with: dart run example/ayrshare_example.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

// Replace with your actual API key
const String AYRSHARE_API_KEY = 'YOUR_API_KEY_HERE';
const String AYRSHARE_BASE_URL = 'https://api.ayrshare.com/api';

void main() async {
  print('🚀 Ayrshare API Integration Examples\n');

  // Example 1: Create a User Profile
  await createUserProfile();

  // Example 2: Publish a Post
  await publishPost();

  // Example 3: Get Post History
  await getPostHistory();

  // Example 4: Get Analytics
  await getAnalytics();

  // Example 5: Get Comments
  await getComments();

  // Example 6: Reply to Comment
  await replyToComment();

  // Example 7: Get Direct Messages
  await getDirectMessages();

  // Example 8: Delete a Post
  await deletePost();
}

/// Example 1: Create a User Profile
/// 
/// Each user in your app should have their own Ayrshare profile
/// This allows you to manage multiple users' social accounts separately
Future<void> createUserProfile() async {
  print('📝 Example 1: Create User Profile');
  print('─────────────────────────────────────');

  try {
    final response = await http.post(
      Uri.parse('$AYRSHARE_BASE_URL/profiles/profile'),
      headers: {
        'Authorization': 'Bearer $AYRSHARE_API_KEY',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': 'User Profile for john@example.com',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Profile created successfully!');
      print('Profile Key: ${data['profileKey']}');
      print('Save this key in your database for this user\n');
    } else {
      print('❌ Error: ${response.body}\n');
    }
  } catch (e) {
    print('❌ Exception: $e\n');
  }
}

/// Example 2: Publish a Post
/// 
/// Post content to multiple social media platforms at once
Future<void> publishPost() async {
  print('📤 Example 2: Publish a Post');
  print('─────────────────────────────────────');

  // Use the profile key from Example 1
  const String userProfileKey = 'USER_PROFILE_KEY_HERE';

  try {
    final response = await http.post(
      Uri.parse('$AYRSHARE_BASE_URL/post'),
      headers: {
        'Authorization': 'Bearer $userProfileKey', // Use user's profile key
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'post': 'Hello from Contentflow Pro! 🚀 #SocialMedia #Automation',
        'platforms': ['facebook', 'twitter', 'linkedin'],
        // Optional: Schedule for later
        // 'scheduleDate': '2024-12-31T10:00:00Z',
        // Optional: Add media
        // 'mediaUrls': ['https://example.com/image.jpg'],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Post published successfully!');
      print('Post ID: ${data['id']}');
      print('Status: ${data['status']}');
      print('Posted to: ${data['postIds']?.keys.join(', ')}\n');
    } else {
      print('❌ Error: ${response.body}\n');
    }
  } catch (e) {
    print('❌ Exception: $e\n');
  }
}

/// Example 3: Get Post History
/// 
/// Retrieve all posts for a user
Future<void> getPostHistory() async {
  print('📜 Example 3: Get Post History');
  print('─────────────────────────────────────');

  const String userProfileKey = 'USER_PROFILE_KEY_HERE';

  try {
    final response = await http.get(
      Uri.parse('$AYRSHARE_BASE_URL/history'),
      headers: {
        'Authorization': 'Bearer $userProfileKey',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Retrieved post history!');
      print('Total posts: ${data['posts']?.length ?? 0}');
      
      // Print first 3 posts
      final posts = data['posts'] as List?;
      if (posts != null && posts.isNotEmpty) {
        print('\nRecent posts:');
        for (var i = 0; i < (posts.length > 3 ? 3 : posts.length); i++) {
          final post = posts[i];
          print('  ${i + 1}. ${post['post']?.substring(0, 50)}...');
          print('     Status: ${post['status']}');
        }
      }
      print('');
    } else {
      print('❌ Error: ${response.body}\n');
    }
  } catch (e) {
    print('❌ Exception: $e\n');
  }
}

/// Example 4: Get Analytics
/// 
/// Get performance metrics for a specific post
Future<void> getAnalytics() async {
  print('📊 Example 4: Get Post Analytics');
  print('─────────────────────────────────────');

  const String userProfileKey = 'USER_PROFILE_KEY_HERE';
  const String postId = 'POST_ID_HERE';

  try {
    final response = await http.post(
      Uri.parse('$AYRSHARE_BASE_URL/analytics/post'),
      headers: {
        'Authorization': 'Bearer $userProfileKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id': postId,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Retrieved analytics!');
      
      // Print analytics for each platform
      final platforms = data['platforms'] as Map?;
      if (platforms != null) {
        platforms.forEach((platform, stats) {
          print('\n$platform:');
          print('  Likes: ${stats['likes'] ?? 0}');
          print('  Comments: ${stats['comments'] ?? 0}');
          print('  Shares: ${stats['shares'] ?? 0}');
          print('  Impressions: ${stats['impressions'] ?? 0}');
        });
      }
      print('');
    } else {
      print('❌ Error: ${response.body}\n');
    }
  } catch (e) {
    print('❌ Exception: $e\n');
  }
}

/// Example 5: Get Comments
/// 
/// Retrieve comments from social media posts
Future<void> getComments() async {
  print('💬 Example 5: Get Comments');
  print('─────────────────────────────────────');

  const String userProfileKey = 'USER_PROFILE_KEY_HERE';

  try {
    final response = await http.get(
      Uri.parse('$AYRSHARE_BASE_URL/comments'),
      headers: {
        'Authorization': 'Bearer $userProfileKey',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Retrieved comments!');
      
      final comments = data['comments'] as List?;
      if (comments != null && comments.isNotEmpty) {
        print('Total comments: ${comments.length}');
        print('\nRecent comments:');
        for (var i = 0; i < (comments.length > 3 ? 3 : comments.length); i++) {
          final comment = comments[i];
          print('  ${i + 1}. ${comment['text']}');
          print('     From: ${comment['from']}');
          print('     Platform: ${comment['platform']}');
        }
      } else {
        print('No comments found.');
      }
      print('');
    } else {
      print('❌ Error: ${response.body}\n');
    }
  } catch (e) {
    print('❌ Exception: $e\n');
  }
}

/// Example 6: Reply to Comment
/// 
/// Reply to a comment on social media
Future<void> replyToComment() async {
  print('↩️  Example 6: Reply to Comment');
  print('─────────────────────────────────────');

  const String userProfileKey = 'USER_PROFILE_KEY_HERE';
  const String commentId = 'COMMENT_ID_HERE';

  try {
    final response = await http.post(
      Uri.parse('$AYRSHARE_BASE_URL/comments'),
      headers: {
        'Authorization': 'Bearer $userProfileKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'commentId': commentId,
        'reply': 'Thank you for your comment! 😊',
      }),
    );

    if (response.statusCode == 200) {
      print('✅ Reply sent successfully!\n');
    } else {
      print('❌ Error: ${response.body}\n');
    }
  } catch (e) {
    print('❌ Exception: $e\n');
  }
}

/// Example 7: Get Direct Messages
/// 
/// Retrieve direct messages from social platforms
Future<void> getDirectMessages() async {
  print('✉️  Example 7: Get Direct Messages');
  print('─────────────────────────────────────');

  const String userProfileKey = 'USER_PROFILE_KEY_HERE';

  try {
    final response = await http.get(
      Uri.parse('$AYRSHARE_BASE_URL/messages'),
      headers: {
        'Authorization': 'Bearer $userProfileKey',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Retrieved messages!');
      
      final messages = data['messages'] as List?;
      if (messages != null && messages.isNotEmpty) {
        print('Total messages: ${messages.length}');
        print('\nRecent messages:');
        for (var i = 0; i < (messages.length > 3 ? 3 : messages.length); i++) {
          final message = messages[i];
          print('  ${i + 1}. ${message['text']}');
          print('     From: ${message['from']}');
          print('     Platform: ${message['platform']}');
        }
      } else {
        print('No messages found.');
      }
      print('');
    } else {
      print('❌ Error: ${response.body}\n');
    }
  } catch (e) {
    print('❌ Exception: $e\n');
  }
}

/// Example 8: Delete a Post
/// 
/// Delete a published post from social media
Future<void> deletePost() async {
  print('🗑️  Example 8: Delete a Post');
  print('─────────────────────────────────────');

  const String userProfileKey = 'USER_PROFILE_KEY_HERE';
  const String postId = 'POST_ID_HERE';

  try {
    final response = await http.delete(
      Uri.parse('$AYRSHARE_BASE_URL/post'),
      headers: {
        'Authorization': 'Bearer $userProfileKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id': postId,
      }),
    );

    if (response.statusCode == 200) {
      print('✅ Post deleted successfully!\n');
    } else {
      print('❌ Error: ${response.body}\n');
    }
  } catch (e) {
    print('❌ Exception: $e\n');
  }
}

