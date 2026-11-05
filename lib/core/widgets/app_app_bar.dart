import 'package:flutter/material.dart';

/// App-wide AppBar. Change look & behaviour here once.
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppBar({super.key, required this.title, this.actions});

  final String title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
        title: Text(title),
        centerTitle: true,
        actions: actions,
      );
}
