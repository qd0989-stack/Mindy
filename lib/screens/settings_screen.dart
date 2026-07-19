import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/user_model.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends StatelessWidget {
  final UserModel user;

  const SettingsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile section
            _buildSectionHeader('Profile'),
            _buildCard([
              _buildProfileTile(context),
            ]),

            const SizedBox(height: 24),

            // Preferences section
            _buildSectionHeader('Preferences'),
            _buildCard([
              _buildListTile(
                icon: Icons.person_outline,
                title: 'Communication Style',
                subtitle: _getStyleName(user.communicationStyle),
                onTap: () => _showCommunicationStyleDialog(context),
              ),
              const Divider(height: 1),
              _buildListTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Manage reminders',
                onTap: () {},
              ),
            ]),

            const SizedBox(height: 24),

            // Privacy section
            _buildSectionHeader('Privacy & Data'),
            _buildCard([
              _buildListTile(
                icon: Icons.download_outlined,
                title: 'Export My Data',
                subtitle: 'Download your conversation history',
                onTap: () => _showExportDialog(context),
              ),
              const Divider(height: 1),
              _buildListTile(
                icon: Icons.delete_outline,
                title: 'Delete Account',
                subtitle: 'Permanently remove your data',
                textColor: AppColors.error,
                onTap: () => _showDeleteDialog(context),
              ),
            ]),

            const SizedBox(height: 24),

            // Support section
            _buildSectionHeader('Support'),
            _buildCard([
              _buildListTile(
                icon: Icons.help_outline,
                title: 'Help & FAQ',
                onTap: () {},
              ),
              const Divider(height: 1),
              _buildListTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                onTap: () {},
              ),
              const Divider(height: 1),
              _buildListTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () {},
              ),
            ]),

            const SizedBox(height: 24),

            // About section
            _buildSectionHeader('About'),
            _buildCard([
              _buildListTile(
                icon: Icons.info_outline,
                title: 'About Mindy',
                subtitle: 'Version 1.0.0',
                onTap: () => _showAboutDialog(context),
              ),
            ]),

            const SizedBox(height: 32),

            // Logout button
            Center(
              child: TextButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout, color: AppColors.textMuted),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Disclaimer
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Icon(Icons.info_outline, color: AppColors.textMuted, size: 20),
                  SizedBox(height: 8),
                  Text(
                    'Mindy is a wellness support tool. It does not replace a licensed therapist, doctor, or emergency services.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildProfileTile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(
                (user.name ?? 'Friend')[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name ?? 'Friend',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.accountType == AccountType.adult ? 'Adult Account' : 'Teen Account',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showEditProfileDialog(context),
            icon: const Icon(Icons.edit_outlined, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.primary),
      title: Text(title, style: TextStyle(color: textColor ?? AppColors.textPrimary)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: AppColors.textMuted)) : null,
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
      onTap: onTap,
    );
  }

  String _getStyleName(CommunicationStyle style) {
    switch (style) {
      case CommunicationStyle.direct:
        return 'Direct';
      case CommunicationStyle.gentle:
        return 'Gentle';
      case CommunicationStyle.balanced:
        return 'Balanced';
    }
  }

  void _showCommunicationStyleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Communication Style'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: CommunicationStyle.values.map((style) {
            return RadioListTile<CommunicationStyle>(
              title: Text(_getStyleName(style)),
              subtitle: Text(_getStyleDescription(style)),
              value: style,
              groupValue: user.communicationStyle,
              onChanged: (value) {
                Navigator.pop(context);
              },
              activeColor: AppColors.primary,
            );
          }).toList(),
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

  String _getStyleDescription(CommunicationStyle style) {
    switch (style) {
      case CommunicationStyle.direct:
        return 'Straight to the point, action-oriented';
      case CommunicationStyle.gentle:
        return 'Soft, supportive, patient approach';
      case CommunicationStyle.balanced:
        return 'Mix of direct and gentle';
    }
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(text: user.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Edit Profile'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'How should Mindy call you?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Export Data'),
        content: const Text(
          'Your conversation history and profile data will be exported as a JSON file.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data export started...')),
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
        backgroundColor: AppColors.surface,
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppColors.error),
            SizedBox(width: 8),
            Text('Delete Account'),
          ],
        ),
        content: const Text(
          'This will permanently delete your account and all associated data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                (route) => false,
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                (route) => false,
              );
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.psychology, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Mindy'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version 1.0.0', style: TextStyle(color: AppColors.textMuted)),
            SizedBox(height: 16),
            Text(
              'Mindy is your voice-activated psychological wellness companion. '
              'Built with care for your mental health and wellbeing.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            SizedBox(height: 16),
            Text(
              '⚠️ Mindy is not a replacement for professional mental health services.',
              style: TextStyle(color: AppColors.warning, fontSize: 12),
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
}
