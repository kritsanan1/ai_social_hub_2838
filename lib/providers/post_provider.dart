import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post_model.dart';
import '../services/ayrshare_service.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';

/// Post State
class PostState {
  final List<PostModel> posts;
  final bool isLoading;
  final String? error;

  const PostState({
    this.posts = const [],
    this.isLoading = false,
    this.error,
  });

  PostState copyWith({
    List<PostModel>? posts,
    bool? isLoading,
    String? error,
  }) {
    return PostState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Post Provider
class PostNotifier extends StateNotifier<PostState> {
  final AyrshareService _ayrshareService;
  final SupabaseService _supabaseService;
  final String userId;

  PostNotifier(
    this._ayrshareService,
    this._supabaseService,
    this.userId,
  ) : super(const PostState()) {
    loadPosts();
  }

  /// Load all posts
  Future<void> loadPosts() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final postsData = await _supabaseService.getUserPosts(userId);
      final posts = postsData.map((data) => PostModel.fromJson(data)).toList();
      state = state.copyWith(posts: posts, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Create and publish a post
  Future<bool> createPost(PostModel post) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Publish to Ayrshare
      final ayrshareResponse = await _ayrshareService.publishPost(post);
      
      // Update post with Ayrshare ID and social post IDs
      final updatedPost = post.copyWith(
        id: ayrshareResponse['id'] as String?,
        status: PostStatus.fromString(ayrshareResponse['status'] as String),
        socialPostIds: ayrshareResponse['postIds'] != null
            ? Map<String, String>.from(ayrshareResponse['postIds'])
            : null,
      );

      // Save to database
      await _supabaseService.createPost(updatedPost.toJson());

      // Reload posts
      await loadPosts();

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Update a post
  Future<bool> updatePost(String postId, PostModel updatedPost) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Update in Ayrshare if it's a scheduled post
      if (updatedPost.isScheduled && updatedPost.id != null) {
        await _ayrshareService.updatePost(
          postId: updatedPost.id!,
          post: updatedPost.content,
          platforms: updatedPost.platforms,
          scheduleDate: updatedPost.scheduleDate,
        );
      }

      // Update in database
      await _supabaseService.updatePost(postId, updatedPost.toJson());

      // Reload posts
      await loadPosts();

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Delete a post
  Future<bool> deletePost(String postId, String? ayrshareId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Delete from Ayrshare if exists
      if (ayrshareId != null) {
        await _ayrshareService.deletePost(ayrshareId);
      }

      // Delete from database
      await _supabaseService.deletePost(postId);

      // Reload posts
      await loadPosts();

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Get scheduled posts
  Future<List<PostModel>> getScheduledPosts() async {
    try {
      final postsData = await _supabaseService.getScheduledPosts(userId);
      return postsData.map((data) => PostModel.fromJson(data)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get posts by date
  List<PostModel> getPostsByDate(DateTime date) {
    return state.posts.where((post) {
      if (post.scheduleDate == null) return false;
      final postDate = post.scheduleDate!;
      return postDate.year == date.year &&
          postDate.month == date.month &&
          postDate.day == date.day;
    }).toList();
  }

  /// Get posts by status
  List<PostModel> getPostsByStatus(PostStatus status) {
    return state.posts.where((post) => post.status == status).toList();
  }
}

/// Post Provider Instance
final postProvider = StateNotifierProvider<PostNotifier, PostState>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    throw Exception('User not authenticated');
  }

  return PostNotifier(
    AyrshareService.instance,
    SupabaseService.instance,
    user.id,
  );
});

/// Scheduled Posts Provider
final scheduledPostsProvider = FutureProvider<List<PostModel>>((ref) async {
  final postNotifier = ref.watch(postProvider.notifier);
  return await postNotifier.getScheduledPosts();
});

/// Posts by Date Provider
final postsByDateProvider = Provider.family<List<PostModel>, DateTime>(
  (ref, date) {
    final postNotifier = ref.watch(postProvider.notifier);
    return postNotifier.getPostsByDate(date);
  },
);

/// Posts by Status Provider
final postsByStatusProvider = Provider.family<List<PostModel>, PostStatus>(
  (ref, status) {
    final postNotifier = ref.watch(postProvider.notifier);
    return postNotifier.getPostsByStatus(status);
  },
);

