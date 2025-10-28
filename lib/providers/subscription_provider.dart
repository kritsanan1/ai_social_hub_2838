import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/stripe_service.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';

/// Subscription State
class SubscriptionState {
  final SubscriptionTier currentTier;
  final DateTime? expiresAt;
  final String? stripeCustomerId;
  final String? stripeSubscriptionId;
  final bool isLoading;
  final String? error;

  const SubscriptionState({
    this.currentTier = SubscriptionTier.free,
    this.expiresAt,
    this.stripeCustomerId,
    this.stripeSubscriptionId,
    this.isLoading = false,
    this.error,
  });

  SubscriptionState copyWith({
    SubscriptionTier? currentTier,
    DateTime? expiresAt,
    String? stripeCustomerId,
    String? stripeSubscriptionId,
    bool? isLoading,
    String? error,
  }) {
    return SubscriptionState(
      currentTier: currentTier ?? this.currentTier,
      expiresAt: expiresAt ?? this.expiresAt,
      stripeCustomerId: stripeCustomerId ?? this.stripeCustomerId,
      stripeSubscriptionId: stripeSubscriptionId ?? this.stripeSubscriptionId,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isActive {
    if (currentTier == SubscriptionTier.free) return true;
    if (expiresAt == null) return false;
    return expiresAt!.isAfter(DateTime.now());
  }

  bool get isExpiringSoon {
    if (expiresAt == null) return false;
    final daysUntilExpiry = expiresAt!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 7 && daysUntilExpiry > 0;
  }
}

/// Subscription Notifier
class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final StripeService _stripeService;
  final SupabaseService _supabaseService;
  final String userId;

  SubscriptionNotifier(
    this._stripeService,
    this._supabaseService,
    this.userId,
  ) : super(const SubscriptionState()) {
    loadSubscription();
  }

  /// Load current subscription
  Future<void> loadSubscription() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await _supabaseService.getUserProfile(userId);
      
      state = state.copyWith(
        currentTier: SubscriptionTier.fromString(
          profile['subscription_tier'] as String? ?? 'free',
        ),
        expiresAt: profile['subscription_expires_at'] != null
            ? DateTime.parse(profile['subscription_expires_at'] as String)
            : null,
        stripeCustomerId: profile['stripe_customer_id'] as String?,
        stripeSubscriptionId: profile['stripe_subscription_id'] as String?,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Create checkout session for subscription
  Future<String?> createCheckoutSession({
    required SubscriptionTier tier,
    required String successUrl,
    required String cancelUrl,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Get or create Stripe customer
      String? customerId = state.stripeCustomerId;
      
      if (customerId == null) {
        final profile = await _supabaseService.getUserProfile(userId);
        final email = profile['email'] as String;
        final fullName = profile['full_name'] as String?;
        
        customerId = await _stripeService.createCustomer(
          email: email,
          name: fullName,
          metadata: {'user_id': userId},
        );
        
        if (customerId != null) {
          await _supabaseService.updateUserProfile(userId, {
            'stripe_customer_id': customerId,
          });
        }
      }

      if (customerId == null) {
        throw Exception('Failed to create Stripe customer');
      }

      // Create checkout session
      final checkoutUrl = await _stripeService.createCheckoutSession(
        customerId: customerId,
        tier: tier,
        successUrl: successUrl,
        cancelUrl: cancelUrl,
      );

      state = state.copyWith(isLoading: false);
      return checkoutUrl;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Upgrade subscription
  Future<bool> upgradeSubscription(SubscriptionTier newTier) async {
    if (newTier == state.currentTier) return false;

    state = state.copyWith(isLoading: true, error: null);
    try {
      // If upgrading from free, create new subscription
      if (state.currentTier == SubscriptionTier.free) {
        // This should be handled via checkout session
        throw Exception('Use createCheckoutSession for new subscriptions');
      }

      // If downgrading to free, cancel subscription
      if (newTier == SubscriptionTier.free) {
        return await cancelSubscription();
      }

      // Update existing subscription
      if (state.stripeSubscriptionId == null) {
        throw Exception('No active subscription found');
      }

      await _stripeService.updateSubscription(
        subscriptionId: state.stripeSubscriptionId!,
        newTier: newTier,
      );

      // Update in database
      await _supabaseService.updateUserProfile(userId, {
        'subscription_tier': newTier.name,
      });

      // Reload subscription
      await loadSubscription();

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

  /// Cancel subscription
  Future<bool> cancelSubscription() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (state.stripeSubscriptionId != null) {
        await _stripeService.cancelSubscription(state.stripeSubscriptionId!);
      }

      // Update to free tier in database
      await _supabaseService.updateUserProfile(userId, {
        'subscription_tier': 'free',
        'subscription_expires_at': null,
        'stripe_subscription_id': null,
      });

      // Reload subscription
      await loadSubscription();

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

  /// Create billing portal session
  Future<String?> createBillingPortalSession(String returnUrl) async {
    if (state.stripeCustomerId == null) {
      return null;
    }

    try {
      return await _stripeService.createBillingPortalSession(
        customerId: state.stripeCustomerId!,
        returnUrl: returnUrl,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Check if user can perform action based on subscription
  bool canPerformAction(String action) {
    switch (action) {
      case 'post':
        // Check post limits based on tier
        return state.isActive;
      case 'analytics':
        return state.currentTier != SubscriptionTier.free;
      case 'advanced_scheduling':
        return state.currentTier != SubscriptionTier.free;
      case 'priority_support':
        return state.currentTier != SubscriptionTier.free;
      case 'custom_integrations':
        return state.currentTier == SubscriptionTier.enterprise;
      default:
        return true;
    }
  }

  /// Get remaining posts for current billing period
  Future<int> getRemainingPosts() async {
    if (state.currentTier.isUnlimited) {
      return -1; // Unlimited
    }

    try {
      // Get posts count for current month
      final postsCount = await _supabaseService.getMonthlyPostsCount(userId);
      final remaining = state.currentTier.postLimit - postsCount;
      return remaining > 0 ? remaining : 0;
    } catch (e) {
      return 0;
    }
  }
}

/// Subscription Provider
final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    throw Exception('User not authenticated');
  }

  return SubscriptionNotifier(
    StripeService.instance,
    SupabaseService.instance,
    user.id,
  );
});

/// Remaining Posts Provider
final remainingPostsProvider = FutureProvider<int>((ref) async {
  final subscriptionNotifier = ref.watch(subscriptionProvider.notifier);
  return await subscriptionNotifier.getRemainingPosts();
});

/// Can Perform Action Provider
final canPerformActionProvider = Provider.family<bool, String>((ref, action) {
  final subscriptionNotifier = ref.watch(subscriptionProvider.notifier);
  return subscriptionNotifier.canPerformAction(action);
});

