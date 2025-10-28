import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env_config.dart';

/// Supabase Service
/// 
/// Handles all Supabase operations including authentication and database
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseClient? _client;

  SupabaseService._();

  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  /// Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  /// Get Supabase client
  SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client!;
  }

  /// Get current user
  User? get currentUser => client.auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Get auth state stream
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  // ==================== Authentication ====================

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: fullName != null ? {'full_name': fullName} : null,
    );
    return response;
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    final response = await client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.flutterquickstart://login-callback/',
    );
    return response;
  }

  /// Sign out
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(email);
  }

  /// Update user profile
  Future<UserResponse> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    final updates = <String, dynamic>{};
    if (fullName != null) updates['full_name'] = fullName;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    return await client.auth.updateUser(
      UserAttributes(data: updates),
    );
  }

  // ==================== Database Operations ====================

  /// Get user profile from database
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final response = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return response;
  }

  /// Create or update user profile
  Future<void> upsertUserProfile(Map<String, dynamic> profile) async {
    await client.from('profiles').upsert(profile);
  }

  /// Get user's posts
  Future<List<Map<String, dynamic>>> getUserPosts(String userId) async {
    final response = await client
        .from('posts')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Create post
  Future<Map<String, dynamic>> createPost(Map<String, dynamic> post) async {
    final response = await client.from('posts').insert(post).select().single();
    return response;
  }

  /// Update post
  Future<void> updatePost(String postId, Map<String, dynamic> updates) async {
    await client.from('posts').update(updates).eq('id', postId);
  }

  /// Delete post
  Future<void> deletePost(String postId) async {
    await client.from('posts').delete().eq('id', postId);
  }

  /// Get scheduled posts
  Future<List<Map<String, dynamic>>> getScheduledPosts(String userId) async {
    final response = await client
        .from('posts')
        .select()
        .eq('user_id', userId)
        .eq('status', 'scheduled')
        .order('schedule_date', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  // ==================== Social Accounts ====================

  /// Get connected social accounts
  Future<List<Map<String, dynamic>>> getConnectedAccounts(
    String userId,
  ) async {
    final response = await client
        .from('social_accounts')
        .select()
        .eq('user_id', userId);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Add social account
  Future<void> addSocialAccount(Map<String, dynamic> account) async {
    await client.from('social_accounts').insert(account);
  }

  /// Remove social account
  Future<void> removeSocialAccount(String accountId) async {
    await client.from('social_accounts').delete().eq('id', accountId);
  }

  // ==================== Analytics ====================

  /// Get post analytics
  Future<Map<String, dynamic>?> getPostAnalytics(String postId) async {
    final response = await client
        .from('post_analytics')
        .select()
        .eq('post_id', postId)
        .maybeSingle();
    return response;
  }

  /// Save post analytics
  Future<void> savePostAnalytics(Map<String, dynamic> analytics) async {
    await client.from('post_analytics').upsert(analytics);
  }

  // ==================== Subscription ====================

  /// Get user subscription
  Future<Map<String, dynamic>?> getUserSubscription(String userId) async {
    final response = await client
        .from('subscriptions')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    return response;
  }

  /// Update subscription
  Future<void> updateSubscription(Map<String, dynamic> subscription) async {
    await client.from('subscriptions').upsert(subscription);
  }

  /// Update user profile fields
  Future<void> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    updates['updated_at'] = DateTime.now().toIso8601String();
    await client.from('profiles').update(updates).eq('id', userId);
  }

  /// Get monthly posts count for subscription limits
  Future<int> getMonthlyPostsCount(String userId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final response = await client
        .from('posts')
        .select('id', const FetchOptions(count: CountOption.exact))
        .eq('user_id', userId)
        .gte('created_at', startOfMonth.toIso8601String());
    return response.count ?? 0;
  }
}

