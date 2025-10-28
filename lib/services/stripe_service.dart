import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';
import '../models/user_model.dart';

/// Stripe Service
/// 
/// Handles payment processing and subscription management via Stripe
class StripeService {
  static final StripeService _instance = StripeService._internal();
  static StripeService get instance => _instance;

  StripeService._internal();

  // Stripe API endpoints
  static const String _baseUrl = 'https://api.stripe.com/v1';

  /// Price IDs for subscription tiers
  /// TODO: Replace with your actual Stripe Price IDs
  static const Map<SubscriptionTier, String> _priceIds = {
    SubscriptionTier.free: '', // Free tier doesn't need a price ID
    SubscriptionTier.pro: 'price_1234567890', // Replace with actual Price ID
    SubscriptionTier.enterprise: 'price_0987654321', // Replace with actual Price ID
  };

  /// Create a Stripe customer
  /// 
  /// Creates a new customer in Stripe for the user
  Future<String?> createCustomer({
    required String email,
    String? name,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/customers'),
        headers: {
          'Authorization': 'Bearer ${EnvConfig.stripeSecretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'email': email,
          if (name != null) 'name': name,
          if (metadata != null)
            ...metadata.map((key, value) => MapEntry('metadata[$key]', value.toString())),
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['id'] as String;
      } else {
        throw Exception('Failed to create customer: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating customer: $e');
    }
  }

  /// Create a checkout session
  /// 
  /// Creates a Stripe Checkout session for subscription
  Future<String?> createCheckoutSession({
    required String customerId,
    required SubscriptionTier tier,
    required String successUrl,
    required String cancelUrl,
  }) async {
    if (tier == SubscriptionTier.free) {
      throw Exception('Cannot create checkout for free tier');
    }

    final priceId = _priceIds[tier];
    if (priceId == null || priceId.isEmpty) {
      throw Exception('Price ID not configured for tier: ${tier.name}');
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/checkout/sessions'),
        headers: {
          'Authorization': 'Bearer ${EnvConfig.stripeSecretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'customer': customerId,
          'mode': 'subscription',
          'line_items[0][price]': priceId,
          'line_items[0][quantity]': '1',
          'success_url': successUrl,
          'cancel_url': cancelUrl,
          'metadata[tier]': tier.name,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url'] as String; // Redirect URL for checkout
      } else {
        throw Exception('Failed to create checkout session: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating checkout session: $e');
    }
  }

  /// Create a subscription
  /// 
  /// Creates a subscription for a customer
  Future<Map<String, dynamic>?> createSubscription({
    required String customerId,
    required SubscriptionTier tier,
  }) async {
    if (tier == SubscriptionTier.free) {
      throw Exception('Cannot create subscription for free tier');
    }

    final priceId = _priceIds[tier];
    if (priceId == null || priceId.isEmpty) {
      throw Exception('Price ID not configured for tier: ${tier.name}');
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/subscriptions'),
        headers: {
          'Authorization': 'Bearer ${EnvConfig.stripeSecretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'customer': customerId,
          'items[0][price]': priceId,
          'metadata[tier]': tier.name,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create subscription: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating subscription: $e');
    }
  }

  /// Get subscription details
  /// 
  /// Retrieves subscription information from Stripe
  Future<Map<String, dynamic>?> getSubscription(String subscriptionId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/subscriptions/$subscriptionId'),
        headers: {
          'Authorization': 'Bearer ${EnvConfig.stripeSecretKey}',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get subscription: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting subscription: $e');
    }
  }

  /// Cancel a subscription
  /// 
  /// Cancels a subscription at the end of the billing period
  Future<bool> cancelSubscription(String subscriptionId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/subscriptions/$subscriptionId'),
        headers: {
          'Authorization': 'Bearer ${EnvConfig.stripeSecretKey}',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error canceling subscription: $e');
    }
  }

  /// Update subscription
  /// 
  /// Updates a subscription to a different tier
  Future<Map<String, dynamic>?> updateSubscription({
    required String subscriptionId,
    required SubscriptionTier newTier,
  }) async {
    if (newTier == SubscriptionTier.free) {
      // Cancel subscription instead
      await cancelSubscription(subscriptionId);
      return null;
    }

    final priceId = _priceIds[newTier];
    if (priceId == null || priceId.isEmpty) {
      throw Exception('Price ID not configured for tier: ${newTier.name}');
    }

    try {
      // First, get current subscription to get item ID
      final subscription = await getSubscription(subscriptionId);
      if (subscription == null) {
        throw Exception('Subscription not found');
      }

      final items = subscription['items']['data'] as List;
      if (items.isEmpty) {
        throw Exception('No subscription items found');
      }

      final itemId = items[0]['id'] as String;

      // Update subscription
      final response = await http.post(
        Uri.parse('$_baseUrl/subscriptions/$subscriptionId'),
        headers: {
          'Authorization': 'Bearer ${EnvConfig.stripeSecretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'items[0][id]': itemId,
          'items[0][price]': priceId,
          'metadata[tier]': newTier.name,
          'proration_behavior': 'always_invoice',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to update subscription: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating subscription: $e');
    }
  }

  /// Create a billing portal session
  /// 
  /// Creates a session for customer to manage their subscription
  Future<String?> createBillingPortalSession({
    required String customerId,
    required String returnUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/billing_portal/sessions'),
        headers: {
          'Authorization': 'Bearer ${EnvConfig.stripeSecretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'customer': customerId,
          'return_url': returnUrl,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url'] as String;
      } else {
        throw Exception('Failed to create portal session: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating portal session: $e');
    }
  }

  /// Get customer details
  /// 
  /// Retrieves customer information from Stripe
  Future<Map<String, dynamic>?> getCustomer(String customerId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/customers/$customerId'),
        headers: {
          'Authorization': 'Bearer ${EnvConfig.stripeSecretKey}',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get customer: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting customer: $e');
    }
  }

  /// List customer subscriptions
  /// 
  /// Gets all subscriptions for a customer
  Future<List<Map<String, dynamic>>> listCustomerSubscriptions(
    String customerId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/subscriptions?customer=$customerId'),
        headers: {
          'Authorization': 'Bearer ${EnvConfig.stripeSecretKey}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('Failed to list subscriptions: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error listing subscriptions: $e');
    }
  }

  /// Handle webhook event
  /// 
  /// Processes Stripe webhook events
  Future<void> handleWebhookEvent(Map<String, dynamic> event) async {
    final eventType = event['type'] as String;

    switch (eventType) {
      case 'customer.subscription.created':
        await _handleSubscriptionCreated(event['data']['object']);
        break;
      case 'customer.subscription.updated':
        await _handleSubscriptionUpdated(event['data']['object']);
        break;
      case 'customer.subscription.deleted':
        await _handleSubscriptionDeleted(event['data']['object']);
        break;
      case 'invoice.payment_succeeded':
        await _handlePaymentSucceeded(event['data']['object']);
        break;
      case 'invoice.payment_failed':
        await _handlePaymentFailed(event['data']['object']);
        break;
      default:
        print('Unhandled webhook event: $eventType');
    }
  }

  Future<void> _handleSubscriptionCreated(Map<String, dynamic> subscription) async {
    // TODO: Update user subscription in database
    print('Subscription created: ${subscription['id']}');
  }

  Future<void> _handleSubscriptionUpdated(Map<String, dynamic> subscription) async {
    // TODO: Update user subscription in database
    print('Subscription updated: ${subscription['id']}');
  }

  Future<void> _handleSubscriptionDeleted(Map<String, dynamic> subscription) async {
    // TODO: Update user subscription to free tier in database
    print('Subscription deleted: ${subscription['id']}');
  }

  Future<void> _handlePaymentSucceeded(Map<String, dynamic> invoice) async {
    // TODO: Update payment status in database
    print('Payment succeeded for invoice: ${invoice['id']}');
  }

  Future<void> _handlePaymentFailed(Map<String, dynamic> invoice) async {
    // TODO: Handle failed payment (send notification, etc.)
    print('Payment failed for invoice: ${invoice['id']}');
  }
}

