import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../data/models/dashboard_profile_model.dart';

class BankEmploymentCard extends StatelessWidget {
  const BankEmploymentCard({
    super.key,
    required this.profile,
  });

  final DashboardProfileDetails? profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_outlined,
                  size: 20,
                  color: scheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Bank & Employment Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: AppSpacing.lg),
            _DetailItem(
              icon: Icons.account_balance,
              title: profile?.bankName != null
                  ? '${profile!.bankName} Bank'
                  : 'N/A',
              subtitle: profile?.branchName != null
                  ? '${profile!.branchName} Branch'
                  : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            _DetailItem(
              icon: Icons.credit_card,
              title: profile?.iban ?? 'N/A',
              subtitle: profile?.bankAccountTitle != null
                  ? 'Title: ${profile!.bankAccountTitle}'
                  : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            _DetailItem(
              icon: Icons.work_outline,
              title: profile?.occupation ?? 'N/A',
              subtitle: profile?.employer != null
                  ? 'Employer: ${profile!.employer}'
                  : null,
            ),
            if (profile?.annualIncome != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _DetailItem(
                icon: Icons.trending_up,
                title: 'Annual Income',
                subtitle: profile!.annualIncome!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({
    required this.icon,
    required this.title,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: scheme.primary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 1),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
