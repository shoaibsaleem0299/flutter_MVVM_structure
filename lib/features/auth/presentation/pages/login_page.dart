import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/login_form.dart';

/// UI only. No controllers, no business logic.
class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authViewModelProvider.select((s) => s.errorMessage), (_, msg) {
      if (msg == null) return;
      AppSnackBar.show(context, msg, isError: true);
      ref.read(authViewModelProvider.notifier).clearError();
    });

    return AppScaffold(
      title: AppLocalizations.of(context).login,
      scrollable: true,
      body: const LoginForm(),
    );
  }
}
