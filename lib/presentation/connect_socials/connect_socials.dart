import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/app_layout.dart';
import '../../theme/app_theme.dart';
import '../../models/post_model.dart';

/// Connect Socials Screen
/// 
/// Manage social media account connections
class ConnectSocials extends ConsumerStatefulWidget {
  const ConnectSocials({Key? key}) : super(key: key);

  @override
  ConsumerState<ConnectSocials> createState() => _ConnectSocialsState();
}

class _ConnectSocialsState extends ConsumerState<ConnectSocials> {
  // Mock connected accounts - will be replaced with real data
  final Map<String, bool> _connectedAccounts = {
    'facebook': true,
    'instagram': true,
    'twitter': false,
    'linkedin': true,
    'tiktok': false,
    'youtube': false,
    'pinterest': false,
    'reddit': false,
  };

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Connect Social Accounts',
      child: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Card(
              elevation: 0,
              color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Connect your social media accounts to start posting and managing content',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 4.h),

            // Connected Accounts Section
            Text(
              'Connected Accounts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),

            ...SocialPlatform.all.map((platform) {
              final isConnected = _connectedAccounts[platform.value] ?? false;
              return _buildPlatformCard(platform, isConnected);
            }).toList(),

            SizedBox(height: 4.h),

            // Help Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.help_outline,
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Need Help?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Having trouble connecting your accounts? Check out our help center for step-by-step guides.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Open help center
                        },
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Visit Help Center'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformCard(SocialPlatform platform, bool isConnected) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(3.w),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getPlatformColor(platform).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _getPlatformIcon(platform),
            color: _getPlatformColor(platform),
            size: 28,
          ),
        ),
        title: Text(
          platform.fullName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          isConnected ? 'Connected' : 'Not connected',
          style: TextStyle(
            color: isConnected ? Colors.green : Colors.grey,
            fontSize: 14,
          ),
        ),
        trailing: isConnected
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _showDisconnectDialog(platform),
                    icon: const Icon(Icons.close, color: Colors.red),
                    tooltip: 'Disconnect',
                  ),
                ],
              )
            : ElevatedButton(
                onPressed: () => _connectAccount(platform),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getPlatformColor(platform),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Connect'),
              ),
      ),
    );
  }

  Color _getPlatformColor(SocialPlatform platform) {
    switch (platform) {
      case SocialPlatform.facebook:
        return const Color(0xFF1877F2);
      case SocialPlatform.instagram:
        return const Color(0xFFE4405F);
      case SocialPlatform.twitter:
        return const Color(0xFF1DA1F2);
      case SocialPlatform.linkedin:
        return const Color(0xFF0A66C2);
      case SocialPlatform.tiktok:
        return const Color(0xFF000000);
      case SocialPlatform.youtube:
        return const Color(0xFFFF0000);
      case SocialPlatform.pinterest:
        return const Color(0xFFE60023);
      case SocialPlatform.reddit:
        return const Color(0xFFFF4500);
      default:
        return Colors.grey;
    }
  }

  IconData _getPlatformIcon(SocialPlatform platform) {
    switch (platform) {
      case SocialPlatform.facebook:
        return Icons.facebook;
      case SocialPlatform.instagram:
        return Icons.camera_alt;
      case SocialPlatform.twitter:
        return Icons.tag;
      case SocialPlatform.linkedin:
        return Icons.work;
      case SocialPlatform.youtube:
        return Icons.play_circle_outline;
      default:
        return Icons.public;
    }
  }

  void _connectAccount(SocialPlatform platform) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Simulate connection delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    Navigator.pop(context);

    // TODO: Implement actual OAuth connection via Ayrshare
    // For now, just update the state
    setState(() {
      _connectedAccounts[platform.value] = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${platform.fullName} connected successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showDisconnectDialog(SocialPlatform platform) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect Account'),
        content: Text(
          'Are you sure you want to disconnect your ${platform.fullName} account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _disconnectAccount(platform);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }

  void _disconnectAccount(SocialPlatform platform) {
    // TODO: Implement actual disconnection via Ayrshare
    setState(() {
      _connectedAccounts[platform.value] = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${platform.fullName} disconnected'),
      ),
    );
  }
}

