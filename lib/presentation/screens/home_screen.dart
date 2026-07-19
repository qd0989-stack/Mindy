import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/memory.dart';
import '../../services/storage_service.dart';
import '../../core/di/injection.dart';
import '../blocs/app_bloc.dart';

/// Home dashboard screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserMemory? _memory;

  @override
  void initState() {
    super.initState();
    _loadMemory();
  }

  Future<void> _loadMemory() async {
    final appState = context.read<AppBloc>().state;
    if (appState is AppReady && appState.user != null) {
      final storage = getIt<StorageService>();
      final memory = await storage.getUserMemory();
      if (mounted) {
        setState(() => _memory = memory);
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final user = state is AppReady ? state.user : null;
        final userName = user?.name ?? 'there';

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting
                  Text(
                    _getGreeting(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  Text(
                    userName,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppTheme.spacingXL),

                  // Main call button
                  _buildCallCard(context),

                  const SizedBox(height: AppTheme.spacingL),

                  // Quick actions
                  Text(
                    'How can I help?',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  _buildQuickActions(context),

                  const SizedBox(height: AppTheme.spacingXL),

                  // Recent themes
                  if (_memory != null && _memory!.recurringThemes.isNotEmpty)
                    _buildRecentThemes(context),

                  // Goals
                  if (_memory != null && _memory!.goals.isNotEmpty)
                    _buildGoals(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCallCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTeal.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.self_improvement,
              color: Colors.white,
              size: 50,
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            'Call Mindy',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Talk through what\'s on your mind',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          ElevatedButton(
            onPressed: () => context.push('/call'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryTealDark,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingXXL,
                vertical: AppTheme.spacingM,
              ),
            ),
            child: const Text('Start Conversation'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.chat_bubble_outline,
            label: 'Quick Chat',
            color: AppTheme.accentLavender,
            onTap: () => context.push('/chat'),
          ),
        ),
        const SizedBox(width: AppTheme.spacingM),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.emoji_emotions_outlined,
            label: 'Mood Check',
            color: AppTheme.success,
            onTap: () => _showMoodDialog(context),
          ),
        ),
        const SizedBox(width: AppTheme.spacingM),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.lightbulb_outline,
            label: 'Coping Tips',
            color: AppTheme.warning,
            onTap: () => context.push('/tips'),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentThemes(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Themes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () => context.push('/insights'),
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingM),
        Wrap(
          spacing: AppTheme.spacingS,
          runSpacing: AppTheme.spacingS,
          children: _memory!.recurringThemes.take(5).map((theme) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingM,
                vertical: AppTheme.spacingS,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
              ),
              child: Text(
                theme.theme,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryTealDark,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppTheme.spacingXL),
      ],
    );
  }

  Widget _buildGoals(BuildContext context) {
    final activeGoals = _memory!.goals.where((g) => !g.isCompleted).take(2);
    if (activeGoals.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Goals',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppTheme.spacingM),
        ...activeGoals.map((goal) => _buildGoalTile(context, goal)),
      ],
    );
  }

  Widget _buildGoalTile(BuildContext context, Goal goal) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingS),
            decoration: BoxDecoration(
              color: AppTheme.accentLavender.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.flag_outlined,
              color: AppTheme.accentLavender,
              size: 20,
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (goal.description != null)
                  Text(
                    goal.description!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppTheme.textMuted,
          ),
        ],
      ),
    );
  }

  void _showMoodDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How are you feeling?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: AppTheme.spacingM,
              runSpacing: AppTheme.spacingM,
              children: [
                _MoodButton(emoji: '😊', label: 'Good', color: AppTheme.success),
                _MoodButton(emoji: '😐', label: 'Okay', color: AppTheme.warning),
                _MoodButton(emoji: '😔', label: 'Low', color: AppTheme.accentLavender),
                _MoodButton(emoji: '😰', label: 'Anxious', color: AppTheme.error),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodButton extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;

  const _MoodButton({
    required this.emoji,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recorded: $label')),
        );
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: AppTheme.spacingXS),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
