import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import 'app_app_bar.dart';
import 'loading_indicator.dart';

/// Every screen uses this instead of a raw Scaffold.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.scrollable = false,
    this.isLoading = false,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  final Widget body;

  /// null = no AppBar.
  final String? title;
  final List<Widget>? actions;
  final bool scrollable;

  /// Shows a blocking loader above the content.
  final bool isLoading;
  final EdgeInsetsGeometry padding;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(padding: padding, child: body);
    if (scrollable) content = SingleChildScrollView(child: content);

    return Scaffold(
      appBar: title == null ? null : AppAppBar(title: title!, actions: actions),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: SafeArea(
        child: Stack(
          children: [
            content,
            if (isLoading)
              const Positioned.fill(
                child: ColoredBox(
                  color: Colors.black26,
                  child: LoadingIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
