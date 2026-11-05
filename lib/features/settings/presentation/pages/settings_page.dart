import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: AppStrings.settings,
      padding: EdgeInsets.zero,
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text(AppStrings.logout),
            onTap: () => ref.read(authViewModelProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }
}
