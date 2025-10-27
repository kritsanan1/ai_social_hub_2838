import 'package:dio/dio.dart';
import '../config/env_config.dart';
import '../models/post_model.dart';

/// Ayrshare Service
/// 
/// Handles all Ayrshare API operations
class AyrshareService {
  static AyrshareService? _instance;
  late final Dio _dio;

  AyrshareService._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.ayrshareBaseUrl,
        headers: {
          'Authorization': 'Bearer ${EnvConfig.ayrshareApiKey}',
          'Content-Type': 'application/json',
        },
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    // Add interceptors for logging
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  static AyrshareService get instance {
    _instance ??= AyrshareService._();
    return _instance!;
  }

  /// Set profile key for user-specific operations
  void setProfileKey(String? profileKey) {
    if (profileKey != null) {
      _dio.options.headers['Profile-Key'] = profileKey;
    } else {
      _dio.options.headers.remove('Profile-Key');
    }
  }

  // ==================== Post Management ====================

  /// Publish a post
  Future<Map<String, dynamic>> publishPost(PostModel post) async {
    try {
      final response = await _dio.post('/post', data: post.toAyrshareJson());
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get post history
  Future<List<Map<String, dynamic>>> getPostHistory({
    String? platform,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (platform != null) queryParams['platform'] = platform;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _dio.get('/history', queryParameters: queryParams);
      final data = response.data as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['posts'] ?? []);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete a post
  Future<void> deletePost(String postId) async {
    try {
      await _dio.delete('/post', data: {'id': postId});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update a scheduled post
  Future<Map<String, dynamic>> updatePost({
    required String postId,
    String? post,
    List<String>? platforms,
    DateTime? scheduleDate,
  }) async {
    try {
      final data = <String, dynamic>{'id': postId};
      if (post != null) data['post'] = post;
      if (platforms != null) data['platforms'] = platforms;
      if (scheduleDate != null) {
        data['scheduleDate'] = scheduleDate.toIso8601String();
      }

      final response = await _dio.put('/post', data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== User Profile Management ====================

  /// Create a user profile
  Future<Map<String, dynamic>> createProfile(String title) async {
    try {
      final response = await _dio.post('/profiles/profile', data: {
        'title': title,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get all user profiles
  Future<List<Map<String, dynamic>>> getProfiles() async {
    try {
      final response = await _dio.get('/profiles');
      return List<Map<String, dynamic>>.from(response.data ?? []);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete a user profile
  Future<void> deleteProfile(String profileKey) async {
    try {
      final originalProfileKey = _dio.options.headers['Profile-Key'];
      _dio.options.headers['Profile-Key'] = profileKey;
      await _dio.delete('/profiles/profile');
      if (originalProfileKey != null) {
        _dio.options.headers['Profile-Key'] = originalProfileKey;
      } else {
        _dio.options.headers.remove('Profile-Key');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get user details
  Future<Map<String, dynamic>> getUserDetails() async {
    try {
      final response = await _dio.get('/user');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== Analytics ====================

  /// Get post analytics
  Future<Map<String, dynamic>> getPostAnalytics(String postId) async {
    try {
      final response = await _dio.post('/analytics/post', data: {
        'id': postId,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get social analytics
  Future<Map<String, dynamic>> getSocialAnalytics(String platform) async {
    try {
      final response = await _dio.post('/analytics/social', data: {
        'platforms': [platform],
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== Comments ====================

  /// Get comments on a post
  Future<List<Map<String, dynamic>>> getComments(String postId) async {
    try {
      final response = await _dio.get('/comments', queryParameters: {
        'id': postId,
      });
      return List<Map<String, dynamic>>.from(response.data ?? []);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Post a comment
  Future<Map<String, dynamic>> postComment({
    required String postId,
    required String comment,
    String? platform,
  }) async {
    try {
      final data = {
        'id': postId,
        'comment': comment,
      };
      if (platform != null) data['platform'] = platform;

      final response = await _dio.post('/comments', data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete a comment
  Future<void> deleteComment({
    required String commentId,
    required String platform,
  }) async {
    try {
      await _dio.delete('/comments', data: {
        'id': commentId,
        'platform': platform,
      });
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== Messages ====================

  /// Get messages/conversations
  Future<List<Map<String, dynamic>>> getMessages({
    required String platform,
    String? conversationId,
  }) async {
    try {
      final queryParams = {'platform': platform};
      if (conversationId != null) {
        queryParams['conversationId'] = conversationId;
      }

      final response = await _dio.get('/messages', queryParameters: queryParams);
      return List<Map<String, dynamic>>.from(response.data ?? []);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Send a message
  Future<Map<String, dynamic>> sendMessage({
    required String platform,
    required String recipientId,
    required String message,
    String? mediaUrl,
  }) async {
    try {
      final data = {
        'platform': platform,
        'recipientId': recipientId,
        'message': message,
      };
      if (mediaUrl != null) data['mediaUrl'] = mediaUrl;

      final response = await _dio.post('/messages/send', data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== Media ====================

  /// Upload media
  Future<Map<String, dynamic>> uploadMedia({
    required String filePath,
    required String fileName,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _dio.post('/media/upload', data: formData);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get uploaded media
  Future<List<Map<String, dynamic>>> getMedia() async {
    try {
      final response = await _dio.get('/media');
      return List<Map<String, dynamic>>.from(response.data ?? []);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== Webhooks ====================

  /// Register webhook
  Future<Map<String, dynamic>> registerWebhook({
    required String url,
    required String action,
  }) async {
    try {
      final response = await _dio.post('/hook/webhook', data: {
        'url': url,
        'action': action,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// List webhooks
  Future<List<Map<String, dynamic>>> listWebhooks() async {
    try {
      final response = await _dio.get('/hook/webhook');
      return List<Map<String, dynamic>>.from(response.data ?? []);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Unregister webhook
  Future<void> unregisterWebhook(String action) async {
    try {
      await _dio.delete('/hook/webhook', data: {'action': action});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== Error Handling ====================

  Exception _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response!.data;
      final message = data is Map ? data['message'] ?? data['error'] : data;
      return Exception('Ayrshare API Error: $message');
    } else {
      return Exception('Network Error: ${error.message}');
    }
  }
}

