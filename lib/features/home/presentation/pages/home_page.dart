import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../viewmodels/home_state.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/bank_employment_card.dart';
import '../widgets/dashboard_header_card.dart';
import '../widgets/kyc_documents_card.dart';
import '../widgets/kyc_trading_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);

    ref.listen(homeViewModelProvider.select((s) => s.errorMessage), (_, msg) {
      if (msg != null) {
        AppSnackBar.show(context, msg, isError: true);
        ref.read(homeViewModelProvider.notifier).clearError();
      }
    });

    return AppScaffold(
      title: 'Dashboard',
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Settings',
          onPressed: () => context.push(Routes.settings),
        ),
      ],
      body: _buildBody(context, ref, state),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, HomeState state) {
    if (state.isLoading && state.profile == null) {
      return const LoadingIndicator();
    }

    if (state.profile == null && state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Retry',
                onPressed: () =>
                    ref.read(homeViewModelProvider.notifier).loadDashboard(),
              ),
            ],
          ),
        ),
      );
    }

    final profile = state.profile!;
    return RefreshIndicator(
      onRefresh: () => ref
          .read(homeViewModelProvider.notifier)
          .loadDashboard(isRefresh: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          DashboardHeaderCard(profile: profile),
          const SizedBox(height: AppSpacing.md),
          KycTradingCard(profile: profile.profile),
          const SizedBox(height: AppSpacing.md),
          BankEmploymentCard(profile: profile.profile),
          const SizedBox(height: AppSpacing.md),
          KycDocumentsCard(documents: profile.kycDocuments),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
