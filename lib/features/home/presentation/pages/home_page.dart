import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/widgets/app_scaffold.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: AppStrings.home,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => context.push(Routes.settings),
        ),
      ],
      body: const Center(child: Text('Home')),
    );
  }
}
