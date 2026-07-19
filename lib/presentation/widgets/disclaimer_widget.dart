import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

/// Disclaimer widget shown at first launch and call start
class DisclaimerWidget extends StatelessWidget {
  final VoidCallback onAcknowledge;
  final bool isCompact;

  const DisclaimerWidget({
    super.key,
    required this.onAcknowledge,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompact(context);
    }
    return _buildFull(context);
  }

  Widget _buildFull(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: AppTheme.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.info,
                  size: 28,
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Text(
                    'Important Notice',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.info,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            AppConstants.disclaimerText,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppTheme.spacingL),
          ElevatedButton(
            onPressed: onAcknowledge,
            child: const Text('I Understand'),
          ),
        ],
      ),
    );
  }

  Widget _buildCompact(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      decoration: BoxDecoration(
        color: AppTheme.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppTheme.info,
            size: 18,
          ),
          const SizedBox(width: AppTheme.spacingS),
          Expanded(
            child: Text(
              AppConstants.disclaimerText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
