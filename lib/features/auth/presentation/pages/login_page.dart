import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../viewmodels/login_viewmodel.dart';
import '../widgets/login_form.dart';

/// Pure View for user login. Listens to ViewModel error messages only.
class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(loginViewModelProvider.select((s) => s.errorMessage), (_, msg) {
      if (msg == null) return;
      AppSnackBar.show(context, msg, isError: true);
      ref.read(loginViewModelProvider.notifier).clearError();
    });

    return const AppScaffold(
      title: AppStrings.login,
      scrollable: true,
      body: LoginForm(),
    );
  }
}
