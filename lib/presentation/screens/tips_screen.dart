import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Coping tips and strategies screen
class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coping Strategies'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lightbulb,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Evidence-Informed',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white.withOpacity(0.8),
                              ),
                        ),
                        Text(
                          'Strategies backed by research',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingXL),

            // CBT section
            _buildFrameworkSection(
              context,
              title: 'Cognitive Behavioral Therapy (CBT)',
              description: 'Change thought patterns to change how you feel',
              color: AppTheme.primaryTeal,
              strategies: [
                _Tip(
                  title: 'Thought Challenging',
                  description:
                      'When you notice a negative thought, ask: Is this true? What evidence supports or contradicts it? What would I tell a friend in this situation?',
                  example: '"I always mess everything up" → "I made a mistake, but I\'ve also done well in many situations."',
                ),
                _Tip(
                  title: 'Behavioral Activation',
                  description:
                      'When feeling low, small actions can help. Start with one small, pleasurable activity — like taking a walk or calling a friend.',
                  example: 'Set a goal: "I will do one enjoyable thing today, no matter how small."',
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingL),

            // ACT section
            _buildFrameworkSection(
              context,
              title: 'Acceptance & Commitment Therapy (ACT)',
              description: 'Accept difficult feelings while moving forward',
              color: AppTheme.accentLavender,
              strategies: [
                _Tip(
                  title: 'Defusion Techniques',
                  description:
                      'Create distance from unhelpful thoughts by labeling them: "I\'m having the thought that I\'m not good enough."',
                  example: '"I\'m a failure" → "I\'m noticing I\'m having the thought \'I\'m a failure\'"',
                ),
                _Tip(
                  title: 'Values Clarification',
                  description:
                      'Ask yourself: What really matters to me? If I weren\'t struggling, what would I be doing?',
                  example: 'Write down 3 values that are important to you and one small action aligned with each.',
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingL),

            // DBT section
            _buildFrameworkSection(
              context,
              title: 'Dialectical Behavior Therapy (DBT)',
              description: 'Skills for emotional regulation and distress tolerance',
              color: AppTheme.success,
              strategies: [
                _Tip(
                  title: 'TIPP Skills (Crisis Survival)',
                  description:
                      'When overwhelmed: Temperature change (cold water), Intense exercise, Paced breathing, Progressive relaxation.',
                  example: 'Hold ice cubes or splash cold water on your face to quickly calm your nervous system.',
                ),
                _Tip(
                  title: 'Radical Acceptance',
                  description:
                      'Accept reality as it is, not as you wish it were. This doesn\'t mean approving — it means reducing suffering by not fighting what\'s already happened.',
                  example: 'Instead of "This shouldn\'t have happened," try "This happened, and I can cope with it."',
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingL),

            // General wellness
            _buildFrameworkSection(
              context,
              title: 'General Wellness',
              description: 'Foundation habits that support mental health',
              color: AppTheme.warning,
              strategies: [
                _Tip(
                  title: 'Sleep Hygiene',
                  description:
                      'Quality sleep affects everything: mood, thinking, stress tolerance. Try a consistent bedtime routine.',
                  example: 'No screens 1 hour before bed, cool dark room, consistent sleep/wake times.',
                ),
                _Tip(
                  title: 'Physical Activity',
                  description:
                      'Movement releases endorphins and reduces stress hormones. Even a 10-minute walk helps.',
                  example: 'Take a short walk outside, especially in daylight. Natural light helps regulate mood.',
                ),
                _Tip(
                  title: 'Social Connection',
                  description:
                      'Humans need connection. Even brief positive interactions with others boost wellbeing.',
                  example: 'Send a quick message to someone you care about, or share something you\'re grateful for.',
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingXL),

            // Disclaimer
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: AppTheme.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.info, size: 20),
                  const SizedBox(width: AppTheme.spacingS),
                  Expanded(
                    child: Text(
                      'These strategies are general wellness tools, not a replacement for professional support.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.info,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingXL),
          ],
        ),
      ),
    );
  }

  Widget _buildFrameworkSection(
    BuildContext context, {
    required String title,
    required String description,
    required Color color,
    required List<_Tip> strategies,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingM),
        ...strategies.map((tip) => _buildTipCard(context, tip, color)),
      ],
    );
  }

  Widget _buildTipCard(BuildContext context, _Tip tip, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.softShadow,
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingXS),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.psychology, color: color, size: 16),
              ),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                tip.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            tip.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (tip.example.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingS),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.format_quote, color: AppTheme.textMuted, size: 16),
                  const SizedBox(width: AppTheme.spacingXS),
                  Expanded(
                    child: Text(
                      tip.example,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Tip {
  final String title;
  final String description;
  final String example;

  const _Tip({
    required this.title,
    required this.description,
    this.example = '',
  });
}
