import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/advanced_options_widget.dart';
import './widgets/ai_suggestions_widget.dart';
import './widgets/media_attachment_widget.dart';
import './widgets/platform_preview_widget.dart';
import './widgets/platform_selector_widget.dart';
import './widgets/scheduling_widget.dart';

class PostCreation extends StatefulWidget {
  const PostCreation({Key? key}) : super(key: key);

  @override
  State<PostCreation> createState() => _PostCreationState();
}

class _PostCreationState extends State<PostCreation> {
  final TextEditingController _contentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _contentFocusNode = FocusNode();

  // Post content state
  String _content = '';
  List<String> _selectedPlatforms = ['instagram'];
  List<XFile> _attachedMedia = [];
  String _characterLimitText = 'Instagram: 2200 characters';
  int _currentCharacterCount = 0;

  // Scheduling state
  bool _isScheduled = false;
  DateTime? _scheduledDateTime;

  // Advanced options state
  List<String> _selectedHashtags = [];
  String? _selectedLocation;
  String _selectedAudience = 'Public';

  // UI state
  bool _isPosting = false;
  bool _isDraftSaved = false;

  @override
  void initState() {
    super.initState();
    _contentController.addListener(_onContentChanged);
    _autoSaveDraft();
  }

  @override
  void dispose() {
    _contentController.removeListener(_onContentChanged);
    _contentController.dispose();
    _scrollController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _onContentChanged() {
    setState(() {
      _content = _contentController.text;
      _currentCharacterCount = _content.length;
    });
    _autoSaveDraft();
  }

  void _autoSaveDraft() {
    // Auto-save draft every 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && _content.isNotEmpty) {
        setState(() {
          _isDraftSaved = true;
        });
        // Here you would typically save to local storage or backend
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _isDraftSaved = false;
            });
          }
        });
      }
    });
  }

  void _onSuggestionTap(String suggestion) {
    final currentText = _contentController.text;
    final newText =
        currentText.isEmpty ? suggestion : '$currentText\n\n$suggestion';
    _contentController.text = newText;
    _contentController.selection = TextSelection.fromPosition(
      TextPosition(offset: newText.length),
    );
    _contentFocusNode.requestFocus();
  }

  void _onPlatformsChanged(List<String> platforms) {
    setState(() {
      _selectedPlatforms = platforms;
    });
  }

  void _onCharacterLimitChanged(String limitText) {
    setState(() {
      _characterLimitText = limitText;
    });
  }

  void _onMediaChanged(List<XFile> media) {
    setState(() {
      _attachedMedia = media;
    });
  }

  void _onSchedulingChanged(bool isScheduled, DateTime? dateTime) {
    setState(() {
      _isScheduled = isScheduled;
      _scheduledDateTime = dateTime;
    });
  }

  void _onHashtagsChanged(List<String> hashtags) {
    setState(() {
      _selectedHashtags = hashtags;
    });
  }

  void _onLocationChanged(String? location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  void _onAudienceChanged(String audience) {
    setState(() {
      _selectedAudience = audience;
    });
  }

  Color _getCharacterCountColor() {
    if (_selectedPlatforms.isEmpty)
      return AppTheme.getTextColor(context, secondary: true);

    // Get minimum character limit from selected platforms
    final Map<String, int> platformLimits = {
      'instagram': 2200,
      'facebook': 63206,
      'twitter': 280,
      'linkedin': 3000,
      'tiktok': 2200,
    };

    int minLimit = _selectedPlatforms
        .map((platform) => platformLimits[platform] ?? 2200)
        .reduce((a, b) => a < b ? a : b);

    double percentage = _currentCharacterCount / minLimit;

    if (percentage >= 1.0) return AppTheme.errorLight;
    if (percentage >= 0.8) return AppTheme.warningLight;
    return AppTheme.successLight;
  }

  Future<void> _handlePost() async {
    if (_content.trim().isEmpty && _attachedMedia.isEmpty) {
      _showErrorDialog('Please add content or media to your post.');
      return;
    }

    if (_selectedPlatforms.isEmpty) {
      _showErrorDialog('Please select at least one platform to post to.');
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      // Simulate posting process
      await Future.delayed(const Duration(seconds: 3));

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(
            'Failed to ${_isScheduled ? 'schedule' : 'publish'} post. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Error',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.errorLight,
            ),
          ),
          content: Text(
            message,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Success!',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.successLight,
            ),
          ),
          content: Text(
            _isScheduled
                ? 'Your post has been scheduled successfully!'
                : 'Your post has been published successfully!',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Return to previous screen
              },
              child: const Text('View Posts'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetForm();
              },
              child: const Text('Create Another'),
            ),
          ],
        );
      },
    );
  }

  void _resetForm() {
    setState(() {
      _content = '';
      _contentController.clear();
      _selectedPlatforms = ['instagram'];
      _attachedMedia = [];
      _isScheduled = false;
      _scheduledDateTime = null;
      _selectedHashtags = [];
      _selectedLocation = null;
      _selectedAudience = 'Public';
      _currentCharacterCount = 0;
      _characterLimitText = 'Instagram: 2200 characters';
    });
  }

  void _handleCancel() {
    if (_content.isNotEmpty || _attachedMedia.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Discard Post?',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'You have unsaved changes. Are you sure you want to discard this post?',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Keep Editing'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.errorLight,
                ),
                child: const Text('Discard'),
              ),
            ],
          );
        },
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Create Post',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: _handleCancel,
          icon: CustomIconWidget(
            iconName: 'close',
            size: 6.w,
            color: AppTheme.getTextColor(context),
          ),
        ),
        actions: [
          if (_isDraftSaved)
            Padding(
              padding: EdgeInsets.only(right: 2.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'cloud_done',
                    size: 4.w,
                    color: AppTheme.successLight,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    'Saved',
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.successLight,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: ElevatedButton(
              onPressed: _isPosting ? null : _handlePost,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _isPosting
                  ? SizedBox(
                      width: 4.w,
                      height: 4.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: _isScheduled ? 'schedule' : 'send',
                          size: 4.w,
                          color: Colors.white,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          _isScheduled ? 'Schedule' : 'Post',
                          style: AppTheme.lightTheme.textTheme.labelLarge
                              ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AI Suggestions
              AiSuggestionsWidget(
                onSuggestionTap: _onSuggestionTap,
                onRegenerate: () {
                  HapticFeedback.lightImpact();
                  // Regeneration logic handled in widget
                },
              ),

              SizedBox(height: 2.h),

              // Content Input
              Container(
                width: double.infinity,
                constraints: BoxConstraints(minHeight: 20.h),
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.getSurfaceColor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _contentFocusNode.hasFocus
                        ? AppTheme.lightTheme.primaryColor
                        : AppTheme.getBorderColor(context),
                    width: _contentFocusNode.hasFocus ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _contentController,
                      focusNode: _contentFocusNode,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText:
                            'What\'s on your mind? Share your thoughts, ideas, or updates...',
                        border: InputBorder.none,
                        hintStyle:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color:
                              AppTheme.getTextColor(context, secondary: true),
                        ),
                      ),
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.getTextColor(context),
                        height: 1.5,
                      ),
                      onChanged: (value) => _onContentChanged(),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _characterLimitText,
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color:
                                AppTheme.getTextColor(context, secondary: true),
                          ),
                        ),
                        Text(
                          '$_currentCharacterCount',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: _getCharacterCountColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              // Platform Selector
              PlatformSelectorWidget(
                selectedPlatforms: _selectedPlatforms,
                onPlatformsChanged: _onPlatformsChanged,
                onCharacterLimitChanged: _onCharacterLimitChanged,
              ),

              SizedBox(height: 3.h),

              // Media Attachment
              MediaAttachmentWidget(
                attachedMedia: _attachedMedia,
                onMediaChanged: _onMediaChanged,
              ),

              SizedBox(height: 3.h),

              // Scheduling
              SchedulingWidget(
                isScheduled: _isScheduled,
                scheduledDateTime: _scheduledDateTime,
                onSchedulingChanged: _onSchedulingChanged,
              ),

              SizedBox(height: 3.h),

              // Advanced Options
              AdvancedOptionsWidget(
                selectedHashtags: _selectedHashtags,
                selectedLocation: _selectedLocation,
                selectedAudience: _selectedAudience,
                onHashtagsChanged: _onHashtagsChanged,
                onLocationChanged: _onLocationChanged,
                onAudienceChanged: _onAudienceChanged,
              ),

              SizedBox(height: 3.h),

              // Platform Preview
              PlatformPreviewWidget(
                selectedPlatforms: _selectedPlatforms,
                content: _content,
                hashtags: _selectedHashtags,
                location: _selectedLocation,
              ),

              SizedBox(height: 10.h), // Extra space for keyboard
            ],
          ),
        ),
      ),
    );
  }
}
