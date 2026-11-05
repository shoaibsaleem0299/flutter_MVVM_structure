import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../viewmodels/auth_viewmodel.dart';

/// Reads the ViewModel once (no rebuilds); only the button listens to loading.
class LoginForm extends ConsumerWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final vm = ref.read(authViewModelProvider.notifier);

    return Form(
      key: vm.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            controller: vm.emailController,
            label: l10n.email,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: Validators.email,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: vm.passwordController,
            label: l10n.password,
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            textInputAction: TextInputAction.done,
            validator: Validators.password,
            onSubmitted: (_) => vm.login(),
          ),
          const SizedBox(height: AppSpacing.lg),
          Consumer(
            builder: (_, ref, __) {
              final isLoading = ref.watch(
                authViewModelProvider.select((s) => s.isLoading),
              );
              return AppButton(
                label: l10n.login,
                isLoading: isLoading,
                onPressed: vm.login,
              );
            },
          ),
        ],
      ),
    );
  }
}
