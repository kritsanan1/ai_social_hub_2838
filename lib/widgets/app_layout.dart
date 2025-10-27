import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_sidebar.dart';

/// Base Layout with Sidebar
/// 
/// Wraps screens with consistent layout including sidebar navigation
class AppLayout extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const AppLayout({
    Key? key,
    required this.child,
    this.title,
    this.actions,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.path;

    return Scaffold(
      appBar: AppBar(
        title: title != null ? Text(title!) : null,
        actions: actions,
      ),
      drawer: AppSidebar(currentRoute: currentRoute),
      body: child,
      floatingActionButton: floatingActionButton,
    );
  }
}

