# API Usage Examples - Contentflow Pro

This document provides practical examples of using the various APIs and services in Contentflow Pro.

---

## Table of Contents

1. [Authentication Examples](#authentication-examples)
2. [Post Management Examples](#post-management-examples)
3. [Subscription Examples](#subscription-examples)
4. [Social Account Examples](#social-account-examples)
5. [Analytics Examples](#analytics-examples)
6. [Complete User Journey Examples](#complete-user-journey-examples)

---

## Authentication Examples

### Sign Up New User

```dart
// In your UI widget
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        final success = await ref.read(authProvider.notifier).signUp(
          email: 'user@example.com',
          password: 'securePassword123',
          fullName: 'John Doe',
        );
        
        if (success) {
          context.goToDashboard();
        } else {
          // Show error
          final error = ref.read(authProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error ?? 'Sign up failed')),
          );
        }
      },
      child: const Text('Sign Up'),
    );
  }
}
```

### Sign In Existing User

```dart
Future<void> signInUser(WidgetRef ref) async {
  final success = await ref.read(authProvider.notifier).signIn(
    email: 'user@example.com',
    password: 'securePassword123',
  );
  
  if (success) {
    // User signed in, router will automatically redirect
    print('Sign in successful');
  } else {
    // Handle error
    final error = ref.read(authProvider).error;
    print('Sign in failed: $error');
  }
}
```

### Sign In with Google

```dart
Future<void> signInWithGoogle(WidgetRef ref) async {
  final success = await ref.read(authProvider.notifier).signInWithGoogle();
  
  if (success) {
    print('Google sign in successful');
  } else {
    print('Google sign in failed');
  }
}
```

### Check Authentication Status

```dart
class ProtectedScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final user = ref.watch(currentUserProvider);
    final userProfile = ref.watch(currentUserProfileProvider);
    
    if (!isAuthenticated) {
      return const Text('Please log in');
    }
    
    return Column(
      children: [
        Text('Email: ${user?.email}'),
        Text('Name: ${userProfile?.fullName ?? "Not set"}'),
        Text('Tier: ${userProfile?.subscriptionTier.displayName}'),
      ],
    );
  }
}
```

### Update User Profile

```dart
Future<void> updateUserProfile(WidgetRef ref) async {
  final success = await ref.read(authProvider.notifier).updateProfile(
    fullName: 'Jane Doe',
    avatarUrl: 'https://example.com/avatar.jpg',
  );
  
  if (success) {
    print('Profile updated');
  }
}
```

### Sign Out

```dart
Future<void> signOut(WidgetRef ref, BuildContext context) async {
  await ref.read(authProvider.notifier).signOut();
  context.goToLogin();
}
```

---

## Post Management Examples

### Create and Publish Post

```dart
Future<void> createPost(WidgetRef ref) async {
  final user = ref.read(currentUserProvider);
  if (user == null) return;
  
  final post = PostModel(
    content: 'Check out our new product! #startup #tech',
    platforms: ['facebook', 'twitter', 'linkedin'],
    mediaUrls: [
      'https://example.com/image1.jpg',
      'https://example.com/image2.jpg',
    ],
    scheduleDate: null, // Publish immediately
    status: PostStatus.pending,
    userId: user.id,
    createdAt: DateTime.now(),
  );
  
  final success = await ref.read(postProvider.notifier).createPost(post);
  
  if (success) {
    print('Post published successfully');
  } else {
    final error = ref.read(postProvider).error;
    print('Failed to publish: $error');
  }
}
```

### Schedule a Post for Later

```dart
Future<void> schedulePost(WidgetRef ref) async {
  final user = ref.read(currentUserProvider);
  if (user == null) return;
  
  final scheduleDate = DateTime.now().add(const Duration(hours: 2));
  
  final post = PostModel(
    content: 'Scheduled post for later',
    platforms: ['instagram', 'facebook'],
    scheduleDate: scheduleDate,
    status: PostStatus.scheduled,
    userId: user.id,
    createdAt: DateTime.now(),
  );
  
  final success = await ref.read(postProvider.notifier).createPost(post);
  
  if (success) {
    print('Post scheduled for ${scheduleDate.toIso8601String()}');
  }
}
```

### Platform-Specific Content

```dart
Future<void> createPostWithPlatformSpecifics(WidgetRef ref) async {
  final user = ref.read(currentUserProvider);
  if (user == null) return;
  
  final post = PostModel(
    content: 'Default content for all platforms',
    platforms: ['twitter', 'linkedin', 'instagram'],
    platformSpecificContent: {
      'twitter': {
        'post': 'Shorter content for Twitter #tech',
      },
      'linkedin': {
        'post': 'Professional content for LinkedIn with detailed information.',
      },
      'instagram': {
        'post': 'Visual content for Instagram ✨📱',
      },
    },
    userId: user.id,
    createdAt: DateTime.now(),
  );
  
  await ref.read(postProvider.notifier).createPost(post);
}
```

### Get All Posts

```dart
class PostListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postState = ref.watch(postProvider);
    
    if (postState.isLoading) {
      return const CircularProgressIndicator();
    }
    
    if (postState.error != null) {
      return Text('Error: ${postState.error}');
    }
    
    return ListView.builder(
      itemCount: postState.posts.length,
      itemBuilder: (context, index) {
        final post = postState.posts[index];
        return ListTile(
          title: Text(post.content),
          subtitle: Text(post.platforms.join(', ')),
          trailing: Text(post.status.displayName),
        );
      },
    );
  }
}
```

### Get Scheduled Posts

```dart
class ScheduledPostsWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduledPostsAsync = ref.watch(scheduledPostsProvider);
    
    return scheduledPostsAsync.when(
      data: (posts) => ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return ListTile(
            title: Text(post.content),
            subtitle: Text(
              'Scheduled for: ${post.scheduleDate?.toString() ?? "N/A"}',
            ),
          );
        },
      ),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

### Get Posts by Date (Calendar)

```dart
class CalendarDayView extends ConsumerWidget {
  final DateTime selectedDate;
  
  const CalendarDayView({required this.selectedDate});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postsByDateProvider(selectedDate));
    
    if (posts.isEmpty) {
      return const Text('No posts for this day');
    }
    
    return Column(
      children: posts.map((post) {
        return Card(
          child: ListTile(
            title: Text(post.content),
            subtitle: Text(post.platforms.join(', ')),
          ),
        );
      }).toList(),
    );
  }
}
```

### Update a Post

```dart
Future<void> updatePost(WidgetRef ref, String postId) async {
  // Get existing post
  final postState = ref.read(postProvider);
  final existingPost = postState.posts.firstWhere(
    (p) => p.id == postId,
  );
  
  // Update post
  final updatedPost = existingPost.copyWith(
    content: 'Updated content',
    scheduleDate: DateTime.now().add(const Duration(days: 1)),
  );
  
  final success = await ref.read(postProvider.notifier).updatePost(
    postId,
    updatedPost,
  );
  
  if (success) {
    print('Post updated successfully');
  }
}
```

### Delete a Post

```dart
Future<void> deletePost(WidgetRef ref, String postId, String? ayrshareId) async {
  final success = await ref.read(postProvider.notifier).deletePost(
    postId,
    ayrshareId,
  );
  
  if (success) {
    print('Post deleted successfully');
  }
}
```

---

## Subscription Examples

### Check Current Subscription

```dart
class SubscriptionWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(subscriptionProvider);
    
    return Column(
      children: [
        Text('Current Tier: ${subscription.currentTier.displayName}'),
        Text('Price: \$${subscription.currentTier.price}/month'),
        if (subscription.expiresAt != null)
          Text('Expires: ${subscription.expiresAt}'),
        if (subscription.isExpiringSoon)
          const Text('⚠️ Expiring soon!'),
        Text('Status: ${subscription.isActive ? "Active" : "Inactive"}'),
      ],
    );
  }
}
```

### Upgrade Subscription

```dart
Future<void> upgradeSubscription(
  WidgetRef ref,
  BuildContext context,
) async {
  final checkoutUrl = await ref
      .read(subscriptionProvider.notifier)
      .createCheckoutSession(
        tier: SubscriptionTier.pro,
        successUrl: 'https://yourapp.com/success',
        cancelUrl: 'https://yourapp.com/cancel',
      );
  
  if (checkoutUrl != null) {
    // Open checkout URL in browser
    await launchUrl(Uri.parse(checkoutUrl));
  } else {
    final error = ref.read(subscriptionProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Failed to create checkout')),
    );
  }
}
```

### Cancel Subscription

```dart
Future<void> cancelSubscription(WidgetRef ref) async {
  final success = await ref
      .read(subscriptionProvider.notifier)
      .cancelSubscription();
  
  if (success) {
    print('Subscription cancelled. Will remain active until end of period.');
  }
}
```

### Check Post Limits

```dart
class PostLimitWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(subscriptionProvider);
    final remainingPostsAsync = ref.watch(remainingPostsProvider);
    
    return remainingPostsAsync.when(
      data: (remaining) {
        if (remaining == -1) {
          return const Text('Unlimited posts');
        }
        return Text('$remaining posts remaining this month');
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

### Check Feature Access

```dart
class FeatureButton extends ConsumerWidget {
  final String feature;
  
  const FeatureButton({required this.feature});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canAccess = ref.watch(
      canPerformActionProvider(feature),
    );
    
    return ElevatedButton(
      onPressed: canAccess
          ? () {
              // Perform action
            }
          : null,
      child: Text(
        canAccess
            ? 'Use $feature'
            : 'Upgrade to use $feature',
      ),
    );
  }
}
```

### Open Billing Portal

```dart
Future<void> openBillingPortal(WidgetRef ref) async {
  final portalUrl = await ref
      .read(subscriptionProvider.notifier)
      .createBillingPortalSession('https://yourapp.com/settings');
  
  if (portalUrl != null) {
    await launchUrl(Uri.parse(portalUrl));
  }
}
```

---

## Social Account Examples

### Connect Social Account

```dart
// Note: Actual OAuth flow happens through Ayrshare dashboard
// This example shows how to save connection status

Future<void> markAccountAsConnected(
  SupabaseService supabase,
  String userId,
  String platform,
) async {
  await supabase.addSocialAccount({
    'user_id': userId,
    'platform': platform,
    'account_name': 'My Account',
    'is_connected': true,
    'connected_at': DateTime.now().toIso8601String(),
  });
}
```

### Get Connected Accounts

```dart
Future<List<Map<String, dynamic>>> getConnectedAccounts(
  SupabaseService supabase,
  String userId,
) async {
  return await supabase.getConnectedAccounts(userId);
}
```

### Display Connected Platforms

```dart
class ConnectedPlatformsWidget extends StatelessWidget {
  final List<String> connectedPlatforms;
  
  @override
  Widget build(BuildContext context) {
    final allPlatforms = SocialPlatform.all;
    
    return Wrap(
      spacing: 8,
      children: allPlatforms.map((platform) {
        final isConnected = connectedPlatforms.contains(platform.value);
        
        return Chip(
          label: Text(platform.displayName),
          avatar: Icon(
            isConnected ? Icons.check_circle : Icons.circle_outlined,
            color: isConnected ? Colors.green : Colors.grey,
          ),
        );
      }).toList(),
    );
  }
}
```

---

## Analytics Examples

### Get Post Analytics

```dart
Future<void> getPostAnalytics(
  AyrshareService ayrshare,
  String postId,
) async {
  try {
    final analytics = await ayrshare.getPostAnalytics(postId);
    
    print('Likes: ${analytics['likes']}');
    print('Comments: ${analytics['comments']}');
    print('Shares: ${analytics['shares']}');
    print('Impressions: ${analytics['impressions']}');
  } catch (e) {
    print('Failed to get analytics: $e');
  }
}
```

### Display Analytics Dashboard

```dart
class AnalyticsDashboard extends StatefulWidget {
  final String postId;
  
  @override
  _AnalyticsDashboardState createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  Map<String, dynamic>? analytics;
  
  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }
  
  Future<void> _loadAnalytics() async {
    final data = await AyrshareService.instance.getPostAnalytics(
      widget.postId,
    );
    setState(() {
      analytics = data;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (analytics == null) {
      return const CircularProgressIndicator();
    }
    
    return Column(
      children: [
        _buildMetricCard('Likes', analytics!['likes'] ?? 0),
        _buildMetricCard('Comments', analytics!['comments'] ?? 0),
        _buildMetricCard('Shares', analytics!['shares'] ?? 0),
        _buildMetricCard('Reach', analytics!['reach'] ?? 0),
      ],
    );
  }
  
  Widget _buildMetricCard(String label, int value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            Text('$value', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }
}
```

---

## Complete User Journey Examples

### New User Onboarding Flow

```dart
class OnboardingFlow extends ConsumerStatefulWidget {
  @override
  _OnboardingFlowState createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  int currentStep = 0;
  
  Future<void> completeOnboarding() async {
    // Step 1: User signs up (already done)
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated) return;
    
    // Step 2: Connect social accounts (redirect to Ayrshare)
    // This would open Ayrshare's OAuth flow
    
    // Step 3: Choose subscription tier
    // Show subscription options
    
    // Step 4: Complete setup
    context.goToDashboard();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stepper(
        currentStep: currentStep,
        onStepContinue: () {
          if (currentStep < 3) {
            setState(() => currentStep++);
          } else {
            completeOnboarding();
          }
        },
        steps: [
          Step(title: const Text('Welcome'), content: const WelcomeStep()),
          Step(title: const Text('Connect'), content: const ConnectStep()),
          Step(title: const Text('Subscribe'), content: const SubscribeStep()),
          Step(title: const Text('Complete'), content: const CompleteStep()),
        ],
      ),
    );
  }
}
```

### Complete Post Publishing Flow

```dart
Future<void> completePostPublishFlow(WidgetRef ref) async {
  // 1. Check subscription limits
  final remainingPosts = await ref
      .read(subscriptionProvider.notifier)
      .getRemainingPosts();
  
  if (remainingPosts == 0) {
    print('Post limit reached. Please upgrade.');
    return;
  }
  
  // 2. Create post
  final user = ref.read(currentUserProvider);
  if (user == null) return;
  
  final post = PostModel(
    content: 'My awesome post!',
    platforms: ['facebook', 'twitter'],
    userId: user.id,
    createdAt: DateTime.now(),
  );
  
  // 3. Publish post
  final success = await ref.read(postProvider.notifier).createPost(post);
  
  if (!success) {
    final error = ref.read(postProvider).error;
    print('Failed to publish: $error');
    return;
  }
  
  // 4. Success! Post is published
  print('Post published successfully!');
  
  // 5. Navigate to dashboard
  // context.goToDashboard();
}
```

---

## Error Handling Examples

### Handling API Errors

```dart
Future<void> handleApiCall(WidgetRef ref) async {
  try {
    final success = await ref.read(postProvider.notifier).createPost(post);
    
    if (success) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post published!')),
      );
    } else {
      // Show error from state
      final error = ref.read(postProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Unknown error')),
      );
    }
  } catch (e) {
    // Handle unexpected errors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Unexpected error: $e')),
    );
  }
}
```

### Retry Logic

```dart
Future<bool> retryOperation(
  Future<bool> Function() operation, {
  int maxRetries = 3,
}) async {
  int attempts = 0;
  
  while (attempts < maxRetries) {
    try {
      final result = await operation();
      if (result) return true;
    } catch (e) {
      attempts++;
      if (attempts >= maxRetries) rethrow;
      
      // Wait before retrying (exponential backoff)
      await Future.delayed(Duration(seconds: 2 * attempts));
    }
  }
  
  return false;
}

// Usage
final success = await retryOperation(
  () => ref.read(postProvider.notifier).createPost(post),
);
```

---

## Resources

- **Ayrshare API Docs**: https://docs.ayrshare.com
- **Supabase Docs**: https://supabase.com/docs
- **Stripe API Docs**: https://stripe.com/docs/api
- **Flutter Riverpod Docs**: https://riverpod.dev

---

**Last Updated**: December 2024  
**Version**: 1.0.0
