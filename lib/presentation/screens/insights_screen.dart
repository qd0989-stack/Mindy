import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Insights and personal growth tracking screen
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary card
            _buildSummaryCard(context),
            const SizedBox(height: AppTheme.spacingL),

            // Mood trends
            Text(
              'Your Journey',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.spacingM),
            _buildJourneyCard(context),
            const SizedBox(height: AppTheme.spacingL),

            // Recurring themes
            Text(
              'Recurring Themes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.spacingM),
            _buildThemesCard(context),
            const SizedBox(height: AppTheme.spacingL),

            // Coping strategies
            Text(
              'What\'s Worked',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.spacingM),
            _buildStrategiesCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTeal.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Week',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(context, '3', 'Conversations'),
              _buildStatItem(context, '2h', 'Talk Time'),
              _buildStatItem(context, '5', 'Themes Explored'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
        ),
      ],
    );
  }

  Widget _buildJourneyCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: AppTheme.accentLavender.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.timeline,
                  color: AppTheme.accentLavender,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Progress',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'Building self-awareness',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
          // Simple progress visualization
          Row(
            children: [
              _buildProgressDot(context, true, 'Week 1'),
              _buildProgressLine(),
              _buildProgressDot(context, true, 'Week 2'),
              _buildProgressLine(),
              _buildProgressDot(context, true, 'Week 3'),
              _buildProgressLine(),
              _buildProgressDot(context, false, 'Week 4'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDot(BuildContext context, bool isActive, String label) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryTeal : AppTheme.textMuted.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: isActive
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : null,
        ),
        const SizedBox(height: AppTheme.spacingXS),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isActive ? AppTheme.textPrimary : AppTheme.textMuted,
              ),
        ),
      ],
    );
  }

  Widget _buildProgressLine() {
    return Expanded(
      child: Container(
        height: 2,
        color: AppTheme.textMuted.withOpacity(0.3),
      ),
    );
  }

  Widget _buildThemesCard(BuildContext context) {
    final themes = [
      {'name': 'Work stress', 'count': 5},
      {'name': 'Sleep', 'count': 3},
      {'name': 'Relationships', 'count': 2},
    ];

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: themes.map((theme) {
          final progress = (theme['count'] as int) / 10;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      theme['name'] as String,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '${theme['count']} mentions',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingS),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppTheme.textMuted.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation(AppTheme.primaryTeal),
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStrategiesCard(BuildContext context) {
    final strategies = [
      {'name': 'Deep breathing exercises', 'framework': 'DBT'},
      {'name': 'Reframing negative thoughts', 'framework': 'CBT'},
      {'name': 'Mindfulness meditation', 'framework': 'ACT'},
    ];

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: strategies.map((strategy) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingS),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: AppTheme.success,
                    size: 16,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strategy['name'] as String,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        strategy['framework'] as String,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppTheme.primaryTeal,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
