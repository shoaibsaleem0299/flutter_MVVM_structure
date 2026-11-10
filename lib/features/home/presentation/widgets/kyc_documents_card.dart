import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../data/models/dashboard_profile_model.dart';

class KycDocumentsCard extends StatelessWidget {
  const KycDocumentsCard({
    super.key,
    required this.documents,
  });

  final List<DashboardKycDocument> documents;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (documents.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.folder_shared_outlined,
                  size: 20,
                  color: scheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'KYC Documents (${documents.length})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: AppSpacing.lg),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: documents.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final doc = documents[index];
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius: AppRadius.roundedSm,
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.insert_drive_file_outlined,
                        color: scheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          doc.displayTitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: doc.isApproved
                              ? AppColors.successContainer
                              : AppColors.warningContainer,
                          borderRadius: AppRadius.roundedXs,
                        ),
                        child: Text(
                          (doc.status ?? 'Pending').toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: doc.isApproved
                                ? AppColors.onSuccessContainer
                                : AppColors.onSuccessWarning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
