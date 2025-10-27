import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

/// App Sidebar Navigation
class AppSidebar extends ConsumerWidget {
  final String currentRoute;

  const AppSidebar({
    Key? key,
    required this.currentRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(currentUserProfileProvider);

    return Drawer(
      child: Container(
        color: AppTheme.lightTheme.scaffoldBackgroundColor,
        child: SafeArea(
          child: Column(
            children: [
              // User Profile Section
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.lightTheme.colorScheme.primary,
                      AppTheme.lightTheme.colorScheme.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      backgroundImage: userProfile?.avatarUrl != null
                          ? NetworkImage(userProfile!.avatarUrl!)
                          : null,
                      child: userProfile?.avatarUrl == null
                          ? Icon(
                              Icons.person,
                              size: 40,
                              color: AppTheme.lightTheme.colorScheme.primary,
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      userProfile?.fullName ?? userProfile?.email ?? 'User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        userProfile?.subscriptionTier.displayName ?? 'Free',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Navigation Items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  children: [
                    _buildNavItem(
                      context,
                      icon: Icons.dashboard_outlined,
                      activeIcon: Icons.dashboard,
                      title: 'Social Dashboard',
                      route: '/dashboard',
                      isActive: currentRoute == '/dashboard',
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.calendar_today_outlined,
                      activeIcon: Icons.calendar_today,
                      title: 'Content Calendar',
                      route: '/calendar',
                      isActive: currentRoute == '/calendar',
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.message_outlined,
                      activeIcon: Icons.message,
                      title: 'Social Messages',
                      route: '/messages',
                      isActive: currentRoute == '/messages',
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.comment_outlined,
                      activeIcon: Icons.comment,
                      title: 'Social Comments',
                      route: '/comments',
                      isActive: currentRoute == '/comments',
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.upload_outlined,
                      activeIcon: Icons.upload,
                      title: 'Upload Posts',
                      route: '/upload',
                      isActive: currentRoute == '/upload',
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.link_outlined,
                      activeIcon: Icons.link,
                      title: 'Connect Socials',
                      route: '/connect',
                      isActive: currentRoute == '/connect',
                    ),
                    const Divider(height: 32),
                    _buildNavItem(
                      context,
                      icon: Icons.credit_card_outlined,
                      activeIcon: Icons.credit_card,
                      title: 'Subscription',
                      route: '/subscription',
                      isActive: currentRoute == '/subscription',
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.person_outline,
                      activeIcon: Icons.person,
                      title: 'Profile',
                      route: '/profile',
                      isActive: currentRoute == '/profile',
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.settings_outlined,
                      activeIcon: Icons.settings,
                      title: 'Settings',
                      route: '/settings',
                      isActive: currentRoute == '/settings',
                    ),
                  ],
                ),
              ),

              // Logout Button
              Padding(
                padding: EdgeInsets.all(4.w),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('ออกจากระบบ'),
                          content: const Text('คุณต้องการออกจากระบบหรือไม่?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('ยกเลิก'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('ออกจากระบบ'),
                            ),
                          ],
                        ),
                      );

                      if (shouldLogout == true) {
                        await ref.read(authProvider.notifier).signOut();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('ออกจากระบบ'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required String route,
    required bool isActive,
  }) {
    return ListTile(
      leading: Icon(
        isActive ? activeIcon : icon,
        color: isActive
            ? AppTheme.lightTheme.colorScheme.primary
            : Colors.grey[600],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isActive
              ? AppTheme.lightTheme.colorScheme.primary
              : Colors.grey[800],
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isActive,
      selectedTileColor:
          AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
      onTap: () {
        Navigator.pop(context); // Close drawer
        context.go(route);
      },
    );
  }
}

