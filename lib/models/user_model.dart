import 'package:freezed_annotation/freezed_annotation.dart';

/// User Model
/// 
/// Represents a user in the application
class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String? ayrshareProfileKey;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final SubscriptionTier subscriptionTier;
  final DateTime? subscriptionExpiresAt;

  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.ayrshareProfileKey,
    required this.createdAt,
    this.updatedAt,
    this.subscriptionTier = SubscriptionTier.free,
    this.subscriptionExpiresAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      ayrshareProfileKey: json['ayrshare_profile_key'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      subscriptionTier: SubscriptionTier.fromString(
        json['subscription_tier'] as String? ?? 'free',
      ),
      subscriptionExpiresAt: json['subscription_expires_at'] != null
          ? DateTime.parse(json['subscription_expires_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'ayrshare_profile_key': ayrshareProfileKey,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'subscription_tier': subscriptionTier.value,
      'subscription_expires_at': subscriptionExpiresAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? ayrshareProfileKey,
    DateTime? createdAt,
    DateTime? updatedAt,
    SubscriptionTier? subscriptionTier,
    DateTime? subscriptionExpiresAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      ayrshareProfileKey: ayrshareProfileKey ?? this.ayrshareProfileKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      subscriptionExpiresAt:
          subscriptionExpiresAt ?? this.subscriptionExpiresAt,
    );
  }

  bool get isSubscriptionActive {
    if (subscriptionTier == SubscriptionTier.free) return true;
    if (subscriptionExpiresAt == null) return false;
    return subscriptionExpiresAt!.isAfter(DateTime.now());
  }

  bool get hasAyrshareProfile => ayrshareProfileKey != null;
}

/// Subscription Tier Enum
enum SubscriptionTier {
  free('free', 'Free', 0, 10),
  pro('pro', 'Pro', 29.99, 100),
  enterprise('enterprise', 'Enterprise', 99.99, -1);

  final String value;
  final String displayName;
  final double price;
  final int postLimit; // -1 means unlimited

  const SubscriptionTier(
    this.value,
    this.displayName,
    this.price,
    this.postLimit,
  );

  static SubscriptionTier fromString(String value) {
    return SubscriptionTier.values.firstWhere(
      (tier) => tier.value == value,
      orElse: () => SubscriptionTier.free,
    );
  }

  bool get isUnlimited => postLimit == -1;
}

