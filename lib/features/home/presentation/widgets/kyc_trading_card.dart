import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../data/models/dashboard_profile_model.dart';

class KycTradingCard extends StatelessWidget {
  const KycTradingCard({
    super.key,
    required this.profile,
  });

  final DashboardProfileDetails? profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isKycApproved = (profile?.kycStatus ?? '').toLowerCase() == 'approved';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 20,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Account & KYC Status',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isKycApproved
                        ? AppColors.successContainer
                        : AppColors.warningContainer,
                    borderRadius: AppRadius.roundedXs,
                  ),
                  child: Text(
                    (profile?.kycStatus ?? 'Pending').toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isKycApproved
                          ? AppColors.onSuccessContainer
                          : AppColors.onSuccessWarning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: AppSpacing.lg),
            _InfoRow(
              label: 'Trading Account No.',
              value: profile?.tradingAccountNo ?? 'N/A',
              isEmphasized: true,
            ),
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(
              label: 'CNIC',
              value: profile?.cnic ?? 'N/A',
            ),
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(
              label: 'Nationality / Status',
              value:
                  '${profile?.nationality ?? "Pakistan"} (${profile?.residentStatus ?? "Resident"})',
            ),
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(
              label: 'City / Address',
              value: profile?.city != null
                  ? '${profile!.city}, ${profile?.address ?? ""}'
                  : 'N/A',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.isEmphasized = false,
  });

  final String label;
  final String value;
  final bool isEmphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isEmphasized ? FontWeight.bold : FontWeight.w500,
            color: isEmphasized ? theme.colorScheme.primary : null,
          ),
        ),
      ],
    );
  }
}
