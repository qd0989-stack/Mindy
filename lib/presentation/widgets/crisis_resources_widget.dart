import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/crisis_detection.dart';
import '../../core/constants/app_constants.dart';

/// Widget displaying crisis resources when risk is detected
class CrisisResourcesWidget extends StatelessWidget {
  final CrisisDetectionResult? crisisResult;
  final List<CrisisResource> resources;
  final VoidCallback? onCallEmergency;
  final VoidCallback? onDismiss;

  const CrisisResourcesWidget({
    super.key,
    this.crisisResult,
    this.resources = const [],
    this.onCallEmergency,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.mediumShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: AppTheme.crisisRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingS),
                  decoration: BoxDecoration(
                    color: AppTheme.crisisRed.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: AppTheme.crisisRed,
                    size: 32,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Support Available',
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppTheme.crisisRed,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        'Professional help is available 24/7',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingL),

          // Emergency call button
          ElevatedButton.icon(
            onPressed: onCallEmergency,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.crisisRed,
              padding: const EdgeInsets.all(AppTheme.spacingM),
            ),
            icon: const Icon(Icons.phone),
            label: Text(
              'Call Emergency (${AppConstants.euEmergencyNumber})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: AppTheme.spacingL),

          // Crisis hotlines
          Text(
            'Crisis Hotlines',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppTheme.spacingM),

          ...resources.map((resource) => _buildResourceTile(context, resource)),

          const SizedBox(height: AppTheme.spacingL),

          // Dismiss button
          if (onDismiss != null)
            TextButton(
              onPressed: onDismiss,
              child: const Text('I\'m okay, continue'),
            ),
        ],
      ),
    );
  }

  Widget _buildResourceTile(BuildContext context, CrisisResource resource) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.textMuted.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingS),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.phone_outlined,
              color: AppTheme.primaryTeal,
              size: 20,
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  '${resource.country} • ${resource.isAvailable24x7 ? "24/7" : "Available"}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingXS,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal,
              borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
            ),
            child: Text(
              resource.phoneNumber,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
