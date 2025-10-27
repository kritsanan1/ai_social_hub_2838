import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';
import '../services/ayrshare_service.dart';

/// Auth State
class AuthState {
  final User? user;
  final UserModel? userProfile;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.userProfile,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    UserModel? userProfile,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      userProfile: userProfile ?? this.userProfile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Auth Provider
class AuthNotifier extends StateNotifier<AuthState> {
  final SupabaseService _supabaseService;
  final AyrshareService _ayrshareService;

  AuthNotifier(this._supabaseService, this._ayrshareService)
      : super(const AuthState()) {
    _init();
  }

  void _init() {
    // Listen to auth state changes
    _supabaseService.authStateChanges.listen((authState) {
      if (authState.event == AuthChangeEvent.signedIn) {
        _loadUserProfile();
      } else if (authState.event == AuthChangeEvent.signedOut) {
        state = const AuthState();
        _ayrshareService.setProfileKey(null);
      }
    });

    // Check if user is already signed in
    if (_supabaseService.isAuthenticated) {
      _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    final user = _supabaseService.currentUser;
    if (user == null) return;

    try {
      final profileData = await _supabaseService.getUserProfile(user.id);
      if (profileData != null) {
        final userProfile = UserModel.fromJson(profileData);
        
        // Set Ayrshare profile key if available
        if (userProfile.ayrshareProfileKey != null) {
          _ayrshareService.setProfileKey(userProfile.ayrshareProfileKey);
        }

        state = state.copyWith(
          user: user,
          userProfile: userProfile,
        );
      } else {
        // Create profile if doesn't exist
        await _createUserProfile(user);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> _createUserProfile(User user) async {
    try {
      // Create Ayrshare profile
      final ayrshareProfile = await _ayrshareService.createProfile(
        user.email ?? 'User ${user.id}',
      );
      final profileKey = ayrshareProfile['profileKey'] as String?;

      // Create user profile in database
      final profile = UserModel(
        id: user.id,
        email: user.email!,
        fullName: user.userMetadata?['full_name'] as String?,
        avatarUrl: user.userMetadata?['avatar_url'] as String?,
        ayrshareProfileKey: profileKey,
        createdAt: DateTime.now(),
        subscriptionTier: SubscriptionTier.free,
      );

      await _supabaseService.upsertUserProfile(profile.toJson());

      if (profileKey != null) {
        _ayrshareService.setProfileKey(profileKey);
      }

      state = state.copyWith(
        user: user,
        userProfile: profile,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _supabaseService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );

      if (response.user != null) {
        await _loadUserProfile();
        state = state.copyWith(isLoading: false);
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        error: 'Sign up failed',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _supabaseService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadUserProfile();
        state = state.copyWith(isLoading: false);
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        error: 'Sign in failed',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final success = await _supabaseService.signInWithGoogle();
      if (success) {
        // Profile will be loaded via auth state listener
        return true;
      }
      state = state.copyWith(
        isLoading: false,
        error: 'Google sign in failed',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
      state = const AuthState();
      _ayrshareService.setProfileKey(null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _supabaseService.resetPassword(email);
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

  /// Update profile
  Future<bool> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    if (state.userProfile == null) return false;

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _supabaseService.updateProfile(
        fullName: fullName,
        avatarUrl: avatarUrl,
      );

      final updatedProfile = state.userProfile!.copyWith(
        fullName: fullName,
        avatarUrl: avatarUrl,
        updatedAt: DateTime.now(),
      );

      await _supabaseService.upsertUserProfile(updatedProfile.toJson());

      state = state.copyWith(
        userProfile: updatedProfile,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Refresh user profile
  Future<void> refreshProfile() async {
    await _loadUserProfile();
  }
}

/// Auth Provider Instance
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    SupabaseService.instance,
    AyrshareService.instance,
  );
});

/// Current User Provider
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

/// Current User Profile Provider
final currentUserProfileProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).userProfile;
});

/// Is Authenticated Provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

