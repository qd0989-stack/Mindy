import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/di/injection.dart';
import '../../services/storage_service.dart';
import '../../domain/entities/user.dart';
import '../blocs/app_bloc.dart';

/// Profile and settings screen
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final user = state is AppReady ? state.user : null;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile header
                _buildProfileHeader(context, user),

                const SizedBox(height: AppTheme.spacingXL),

                // Account section
                _buildSectionHeader(context, 'Account'),
                _buildSettingsTile(
                  context,
                  icon: Icons.person_outline,
                  title: 'Personal Information',
                  subtitle: 'Update your name and details',
                  onTap: () {},
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.calendar_today_outlined,
                  title: 'Date of Birth',
                  subtitle: user?.dateOfBirth != null
                      ? '${user!.dateOfBirth!.day}/${user.dateOfBirth!.month}/${user.dateOfBirth!.year}'
                      : 'Not set',
                  onTap: () {},
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.campaign_outlined,
                  title: 'Account Type',
                  subtitle: user?.accountType == AccountType.adult
                      ? 'Adult'
                      : 'Teen',
                  onTap: () {},
                ),

                const SizedBox(height: AppTheme.spacingL),

                // Subscription section
                _buildSectionHeader(context, 'Subscription'),
                _buildSettingsTile(
                  context,
                  icon: Icons.workspace_premium_outlined,
                  title: 'Mindy Premium',
                  subtitle: user?.subscriptionStatus == SubscriptionStatus.premium
                      ? 'Active'
                      : 'Free tier',
                  trailing: user?.subscriptionStatus != SubscriptionStatus.premium
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingM,
                            vertical: AppTheme.spacingXS,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTeal,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusCircular),
                          ),
                          child: Text(
                            'Upgrade',
                            style:
                                Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                        )
                      : null,
                  onTap: () {},
                ),

                const SizedBox(height: AppTheme.spacingL),

                // Privacy section
                _buildSectionHeader(context, 'Privacy & Data'),
                _buildSettingsTile(
                  context,
                  icon: Icons.download_outlined,
                  title: 'Export My Data',
                  subtitle: 'Download a copy of your data',
                  onTap: () => _showExportDialog(context),
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.delete_outline,
                  title: 'Delete Account',
                  subtitle: 'Permanently delete all data',
                  isDestructive: true,
                  onTap: () => _showDeleteDialog(context),
                ),

                const SizedBox(height: AppTheme.spacingL),

                // About section
                _buildSectionHeader(context, 'About'),
                _buildSettingsTile(
                  context,
                  icon: Icons.info_outline,
                  title: 'About Mindy',
                  subtitle: 'Version 1.0.0',
                  onTap: () => _showAboutDialog(context),
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () {},
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  onTap: () {},
                ),

                const SizedBox(height: AppTheme.spacingXL),

                // Logout button
                Center(
                  child: TextButton.icon(
                    onPressed: () => _logout(context),
                    icon: const Icon(Icons.logout, color: AppTheme.error),
                    label: Text(
                      'Sign Out',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.error,
                          ),
                    ),
                  ),
                ),

                const SizedBox(height: AppTheme.spacingXL),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, User? user) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user?.name?.isNotEmpty == true
                    ? user!.name![0].toUpperCase()
                    : '?',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Welcome',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppTheme.spacingXS),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingS,
                    vertical: AppTheme.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Text(
                    user?.subscriptionStatus == SubscriptionStatus.premium
                        ? 'Premium'
                        : 'Free',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
            ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(AppTheme.spacingS),
          decoration: BoxDecoration(
            color: isDestructive
                ? AppTheme.error.withOpacity(0.1)
                : AppTheme.primaryTeal.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isDestructive ? AppTheme.error : AppTheme.primaryTeal,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isDestructive ? AppTheme.error : AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              )
            : null,
        trailing: trailing ??
            Icon(
              Icons.chevron_right,
              color: AppTheme.textMuted,
            ),
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text(
          'This will generate a downloadable copy of your Mindy data, '
          'including your profile, conversation history, and preferences.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final storage = getIt<StorageService>();
              final data = await storage.exportAllUserData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Data export ready: ${data.keys.length} items'),
                ),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This will permanently delete all your data, including:\n\n'
          '• Your profile\n'
          '• Conversation history\n'
          '• Personalization data\n'
          '• Goals and progress\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            onPressed: () async {
              final storage = getIt<StorageService>();
              await storage.deleteAllUserData();
              Navigator.pop(context);
              context.read<AppBloc>().add(const AppUserLoggedOut());
              context.go('/');
            },
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.self_improvement,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            const Text('Mindy'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'Mindy is a voice-activated psychological wellness companion. '
              'It provides personalized support using evidence-informed '
              'therapeutic frameworks.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppTheme.spacingM),
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
                      'Mindy is not a medical device and does not '
                      'replace professional mental health services.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.info,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    context.read<AppBloc>().add(const AppUserLoggedOut());
    context.go('/');
  }
}
