# Architecture Guide - Contentflow Pro

## 📐 Application Architecture

Contentflow Pro follows a clean, scalable architecture using modern Flutter patterns and best practices.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ Screens  │  │ Widgets  │  │ Dialogs  │  │ Sheets   │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                    State Management Layer                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ Auth     │  │  Post    │  │Subscribe │  │Navigation│   │
│  │ Provider │  │ Provider │  │ Provider │  │  Router  │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                      Business Logic Layer                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                  │
│  │ Services │  │  Models  │  │Validators│                  │
│  └──────────┘  └──────────┘  └──────────┘                  │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                        Data Layer                            │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                  │
│  │ Supabase │  │ Ayrshare │  │  Stripe  │                  │
│  │  Client  │  │   API    │  │   API    │                  │
│  └──────────┘  └──────────┘  └──────────┘                  │
└─────────────────────────────────────────────────────────────┘
```

---

## Layer Details

### 1. Presentation Layer

**Location**: `lib/presentation/`

Contains all UI components:
- **Screens**: Full-page views
- **Widgets**: Reusable UI components
- **Dialogs**: Modal dialogs
- **Bottom Sheets**: Slide-up panels

**Key Principles**:
- Screens are dumb (no business logic)
- Widgets are reusable and composable
- State is managed through Riverpod providers
- UI responds to state changes reactively

**Example Screen Structure**:
```dart
class PostCreation extends ConsumerWidget {
  const PostCreation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch providers
    final authState = ref.watch(authProvider);
    final postState = ref.watch(postProvider);
    
    // Build UI based on state
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: _buildBody(context, ref),
    );
  }
}
```

---

### 2. State Management Layer

**Location**: `lib/providers/`

Uses **Flutter Riverpod** for state management.

**Key Providers**:

#### AuthProvider
- Manages user authentication
- Handles sign in/up/out
- Loads and updates user profile
- Integrates with Supabase Auth and Ayrshare

#### PostProvider
- Manages post CRUD operations
- Publishes posts to social media
- Handles scheduling
- Syncs with Supabase and Ayrshare

#### SubscriptionProvider
- Manages subscription tiers
- Handles Stripe payments
- Checks subscription limits
- Creates checkout sessions

**Provider Pattern**:
```dart
// State class
class AuthState {
  final User? user;
  final UserModel? userProfile;
  final bool isLoading;
  final String? error;
}

// Notifier class
class AuthNotifier extends StateNotifier<AuthState> {
  final SupabaseService _supabaseService;
  final AyrshareService _ayrshareService;
  
  AuthNotifier(this._supabaseService, this._ayrshareService)
      : super(const AuthState());
  
  Future<bool> signIn({required String email, required String password}) async {
    // Implementation
  }
}

// Provider declaration
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    SupabaseService.instance,
    AyrshareService.instance,
  );
});
```

**Why Riverpod?**:
- Type-safe
- Compile-time error checking
- No context needed
- Better testability
- Automatic dependency injection

---

### 3. Business Logic Layer

**Location**: `lib/services/`, `lib/models/`

Contains business logic and data models.

#### Services

**SupabaseService** (`lib/services/supabase_service.dart`):
- Authentication operations
- Database CRUD operations
- Real-time subscriptions
- File storage (optional)

**AyrshareService** (`lib/services/ayrshare_service.dart`):
- Post publishing
- Social account management
- Comments and messages
- Analytics retrieval
- Media upload

**StripeService** (`lib/services/stripe_service.dart`):
- Payment processing
- Subscription management
- Checkout sessions
- Billing portal
- Webhook handling

#### Models

**UserModel** (`lib/models/user_model.dart`):
```dart
class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final SubscriptionTier subscriptionTier;
  
  // Factory constructors for JSON serialization
  factory UserModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

**PostModel** (`lib/models/post_model.dart`):
```dart
class PostModel {
  final String? id;
  final String content;
  final List<String> platforms;
  final DateTime? scheduleDate;
  final PostStatus status;
  
  // Convert to Ayrshare API format
  Map<String, dynamic> toAyrshareJson();
}
```

---

### 4. Data Layer

External services and APIs:

#### Supabase
- PostgreSQL database
- Row Level Security (RLS)
- Authentication
- Real-time subscriptions
- File storage

#### Ayrshare
- Multi-platform posting
- Social account OAuth
- Comments and messages
- Analytics
- Media management

#### Stripe
- Payment processing
- Subscription billing
- Customer portal
- Webhooks
- Invoice management

---

## Navigation Architecture

**Router**: `lib/routes/app_router.dart`

Uses **GoRouter** for declarative routing.

**Features**:
- Named routes
- Authentication guards
- Deep linking support
- Redirect logic
- Error handling

**Example Route**:
```dart
GoRoute(
  path: '/dashboard',
  name: 'dashboard',
  builder: (context, state) => const SocialMediaDashboard(),
  redirect: (context, state) {
    // Redirect to login if not authenticated
    if (!authState.isAuthenticated) {
      return '/login';
    }
    return null;
  },
),
```

**Navigation Extensions**:
```dart
extension NavigationExtension on BuildContext {
  void goToDashboard() => go('/dashboard');
  void goToUpload() => go('/upload');
  // ... more helpers
}

// Usage
context.goToDashboard();
```

---

## Theme Architecture

**Location**: `lib/theme/app_theme.dart`

Comprehensive theming system with light and dark modes.

**Features**:
- Material Design 3
- Google Fonts (Inter)
- Consistent color palette
- Component-specific themes
- Responsive sizing

**Theme Structure**:
```dart
class AppTheme {
  // Color definitions
  static const Color primaryLight = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF3B82F6);
  
  // Light theme
  static ThemeData lightTheme = ThemeData(...);
  
  // Dark theme
  static ThemeData darkTheme = ThemeData(...);
  
  // Helper methods
  static Color getTextColor(BuildContext context);
  static Color getSurfaceColor(BuildContext context);
}
```

---

## Data Flow

### User Authentication Flow

```
User Action (Login)
       ↓
LoginScreen calls ref.read(authProvider.notifier).signIn()
       ↓
AuthNotifier.signIn()
       ↓
SupabaseService.signIn()
       ↓
Supabase Auth API
       ↓
Success: Load user profile
       ↓
AyrshareService.setProfileKey()
       ↓
Update AuthState
       ↓
GoRouter redirects to /dashboard
       ↓
UI rebuilds with new state
```

### Post Creation Flow

```
User fills form in PostCreation screen
       ↓
Calls ref.read(postProvider.notifier).createPost()
       ↓
PostNotifier.createPost()
       ↓
AyrshareService.publishPost() (post to social media)
       ↓
Receive post IDs from platforms
       ↓
SupabaseService.createPost() (save to database)
       ↓
Update PostState
       ↓
UI shows success message
       ↓
Navigate to dashboard
```

### Subscription Upgrade Flow

```
User selects plan in SubscriptionScreen
       ↓
Calls ref.read(subscriptionProvider.notifier).createCheckoutSession()
       ↓
SubscriptionNotifier.createCheckoutSession()
       ↓
Create/Get Stripe customer
       ↓
StripeService.createCheckoutSession()
       ↓
Return checkout URL
       ↓
Open Stripe Checkout in browser
       ↓
User completes payment
       ↓
Stripe webhook → Update Supabase
       ↓
App reloads subscription
       ↓
UI shows updated tier
```

---

## Error Handling

### Service Layer
```dart
try {
  final response = await api.call();
  return response;
} on DioException catch (e) {
  throw _handleError(e);
} catch (e) {
  throw Exception('Unexpected error: $e');
}
```

### Provider Layer
```dart
Future<bool> performAction() async {
  state = state.copyWith(isLoading: true, error: null);
  try {
    await service.performAction();
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
```

### UI Layer
```dart
final state = ref.watch(provider);

if (state.error != null) {
  return ErrorWidget(message: state.error!);
}

if (state.isLoading) {
  return LoadingWidget();
}

return ContentWidget();
```

---

## Security Architecture

### Authentication
- JWT tokens via Supabase
- Secure session management
- Auto-refresh tokens
- Secure storage of credentials

### Database Security
- Row Level Security (RLS) policies
- User can only access their own data
- Server-side validation
- SQL injection prevention

### API Security
- API keys stored securely
- HTTPS only
- Rate limiting
- Input sanitization

### Payment Security
- PCI compliance via Stripe
- No card data stored locally
- Webhook signature verification
- Secure checkout flow

---

## Performance Optimization

### State Management
- Selective rebuilds with Riverpod
- Provider families for parameterized state
- Auto-dispose providers
- Caching frequently accessed data

### UI Performance
- Lazy loading lists
- Image caching
- Pagination for large datasets
- Debouncing search inputs

### Network
- Request caching
- Retry logic
- Connection pooling
- Offline support (future)

---

## Testing Strategy

### Unit Tests
- Test business logic in services
- Test model serialization
- Test utility functions

### Widget Tests
- Test widget rendering
- Test user interactions
- Test state changes

### Integration Tests
- Test complete user flows
- Test navigation
- Test API integration

### Example Test
```dart
void main() {
  group('AuthProvider', () {
    test('signIn updates state correctly', () async {
      // Arrange
      final provider = AuthNotifier(mockSupabase, mockAyrshare);
      
      // Act
      final result = await provider.signIn(
        email: 'test@example.com',
        password: 'password',
      );
      
      // Assert
      expect(result, true);
      expect(provider.state.isAuthenticated, true);
    });
  });
}
```

---

## Scalability Considerations

### Code Organization
- Feature-based directory structure
- Clear separation of concerns
- Reusable components
- Modular architecture

### Performance
- Efficient state management
- Optimized queries
- Caching strategies
- Lazy loading

### Maintainability
- Comprehensive documentation
- Consistent code style
- Type safety
- Error handling

### Extensibility
- Plugin architecture ready
- Easy to add new features
- Decoupled services
- Configurable components

---

## Best Practices

### Code Style
- Follow Dart/Flutter style guide
- Use meaningful names
- Write self-documenting code
- Add comments for complex logic

### State Management
- Keep state immutable
- Use copyWith for updates
- Handle loading and error states
- Avoid deeply nested states

### UI Development
- Build reusable widgets
- Keep widgets small and focused
- Use const constructors
- Leverage theme system

### API Integration
- Handle all error cases
- Implement retry logic
- Log important events
- Validate responses

---

## Future Enhancements

### Planned Features
- Offline support
- Advanced analytics dashboard
- Team collaboration
- White-label solution
- Custom integrations API

### Technical Improvements
- Add more unit tests
- Implement integration tests
- Set up CI/CD pipeline
- Add error tracking (Sentry)
- Implement analytics (Firebase)

---

## Resources

### Flutter
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)

### Riverpod
- [Riverpod Documentation](https://riverpod.dev)
- [State Management Best Practices](https://riverpod.dev/docs/concepts/providers)

### Architecture
- [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples)
- [Clean Architecture in Flutter](https://resocoder.com/flutter-clean-architecture-tdd/)

---

**Last Updated**: December 2024  
**Version**: 1.0.0
