/// Post Model
/// 
/// Represents a social media post
class PostModel {
  final String? id; // Ayrshare post ID
  final String content;
  final List<String> platforms;
  final List<String> mediaUrls;
  final DateTime? scheduleDate;
  final PostStatus status;
  final Map<String, dynamic>? platformSpecificContent;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String userId;
  final Map<String, String>? socialPostIds; // Platform-specific post IDs

  const PostModel({
    this.id,
    required this.content,
    required this.platforms,
    this.mediaUrls = const [],
    this.scheduleDate,
    this.status = PostStatus.draft,
    this.platformSpecificContent,
    required this.createdAt,
    this.updatedAt,
    required this.userId,
    this.socialPostIds,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String?,
      content: json['content'] as String,
      platforms: (json['platforms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      mediaUrls: json['media_urls'] != null
          ? (json['media_urls'] as List<dynamic>)
              .map((e) => e as String)
              .toList()
          : [],
      scheduleDate: json['schedule_date'] != null
          ? DateTime.parse(json['schedule_date'] as String)
          : null,
      status: PostStatus.fromString(json['status'] as String? ?? 'draft'),
      platformSpecificContent:
          json['platform_specific_content'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      userId: json['user_id'] as String,
      socialPostIds: json['social_post_ids'] != null
          ? Map<String, String>.from(json['social_post_ids'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'platforms': platforms,
      'media_urls': mediaUrls,
      'schedule_date': scheduleDate?.toIso8601String(),
      'status': status.value,
      'platform_specific_content': platformSpecificContent,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'user_id': userId,
      'social_post_ids': socialPostIds,
    };
  }

  /// Convert to Ayrshare API format
  Map<String, dynamic> toAyrshareJson() {
    final Map<String, dynamic> data = {
      'post': content,
      'platforms': platforms,
    };

    if (mediaUrls.isNotEmpty) {
      data['mediaUrls'] = mediaUrls;
    }

    if (scheduleDate != null) {
      data['scheduleDate'] = scheduleDate!.toIso8601String();
    }

    if (platformSpecificContent != null) {
      data.addAll(platformSpecificContent!);
    }

    return data;
  }

  PostModel copyWith({
    String? id,
    String? content,
    List<String>? platforms,
    List<String>? mediaUrls,
    DateTime? scheduleDate,
    PostStatus? status,
    Map<String, dynamic>? platformSpecificContent,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    Map<String, String>? socialPostIds,
  }) {
    return PostModel(
      id: id ?? this.id,
      content: content ?? this.content,
      platforms: platforms ?? this.platforms,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      scheduleDate: scheduleDate ?? this.scheduleDate,
      status: status ?? this.status,
      platformSpecificContent:
          platformSpecificContent ?? this.platformSpecificContent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      socialPostIds: socialPostIds ?? this.socialPostIds,
    );
  }

  bool get isScheduled => scheduleDate != null;
  bool get hasMedia => mediaUrls.isNotEmpty;
  bool get isPublished => status == PostStatus.published;
}

/// Post Status Enum
enum PostStatus {
  draft('draft', 'Draft'),
  scheduled('scheduled', 'Scheduled'),
  publishing('publishing', 'Publishing'),
  published('published', 'Published'),
  failed('failed', 'Failed'),
  pending('pending', 'Pending');

  final String value;
  final String displayName;

  const PostStatus(this.value, this.displayName);

  static PostStatus fromString(String value) {
    return PostStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PostStatus.draft,
    );
  }
}

/// Supported Social Media Platforms
enum SocialPlatform {
  facebook('facebook', 'Facebook', 'Facebook'),
  instagram('instagram', 'Instagram', 'Instagram'),
  twitter('twitter', 'Twitter/X', 'X'),
  linkedin('linkedin', 'LinkedIn', 'LinkedIn'),
  tiktok('tiktok', 'TikTok', 'TikTok'),
  youtube('youtube', 'YouTube', 'YouTube'),
  pinterest('pinterest', 'Pinterest', 'Pinterest'),
  reddit('reddit', 'Reddit', 'Reddit'),
  bluesky('bluesky', 'Bluesky', 'Bluesky'),
  threads('threads', 'Threads', 'Threads'),
  telegram('telegram', 'Telegram', 'Telegram'),
  snapchat('snapchat', 'Snapchat', 'Snapchat'),
  gmb('gmb', 'Google Business', 'Google My Business');

  final String value;
  final String displayName;
  final String fullName;

  const SocialPlatform(this.value, this.displayName, this.fullName);

  static SocialPlatform fromString(String value) {
    return SocialPlatform.values.firstWhere(
      (platform) => platform.value == value,
      orElse: () => SocialPlatform.facebook,
    );
  }

  static List<SocialPlatform> get all => SocialPlatform.values;
}

