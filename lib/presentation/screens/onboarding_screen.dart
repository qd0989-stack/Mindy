import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/consent.dart';
import '../blocs/app_bloc.dart';

/// Onboarding flow with account type selection
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Account type
  AccountType? _accountType;
  String? _name;
  DateTime? _dateOfBirth;
  String? _trustedAdultContact;

  // Consent
  bool _consentEssential = false;
  bool _consentAnalytics = false;
  bool _consentPersonalized = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    // Create user
    final user = User(
      id: const Uuid().v4(),
      name: _name,
      dateOfBirth: _dateOfBirth,
      accountType: _accountType ?? AccountType.adult,
      subscriptionStatus: SubscriptionStatus.free,
      trustedAdultContact: _trustedAdultContact,
      createdAt: DateTime.now(),
    );

    // Create consent record
    final consent = ConsentRecord(
      id: const Uuid().v4(),
      odUserId: user.id,
      consents: [
        ConsentItem(
          type: ConsentType.essential,
          isGranted: _consentEssential,
          recordedAt: DateTime.now(),
        ),
        ConsentItem(
          type: ConsentType.analytics,
          isGranted: _consentAnalytics,
          recordedAt: DateTime.now(),
        ),
        ConsentItem(
          type: ConsentType.personalizedExperience,
          isGranted: _consentPersonalized,
          recordedAt: DateTime.now(),
        ),
      ],
      recordedAt: DateTime.now(),
    );

    // Save to BLoC
    context.read<AppBloc>().add(AppUserLoaded(user));
    context.read<AppBloc>().add(AppConsentUpdated(consent));

    // Complete onboarding
    await context.read<AppBloc>().stream.firstWhere(
          (state) => state is AppReady && state.onboardingComplete,
        );

    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _previousPage,
                    )
                  else
                    const SizedBox(width: 48),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: index == _currentPage ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: index <= _currentPage
                                ? AppTheme.primaryTeal
                                : AppTheme.textMuted.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildAccountTypePage(),
                  _buildPersonalInfoPage(),
                  _buildConsentPage(),
                  _buildReviewPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTypePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Welcome to Mindy',
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Let\'s personalize your experience',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingXXL),
          Text(
            'How old are you?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppTheme.spacingM),
          _AccountTypeCard(
            title: 'Adult',
            subtitle: '20 years or older',
            icon: Icons.person,
            isSelected: _accountType == AccountType.adult,
            onTap: () => setState(() => _accountType = AccountType.adult),
          ),
          const SizedBox(height: AppTheme.spacingM),
          _AccountTypeCard(
            title: 'Teen',
            subtitle: 'Under 20 years old',
            icon: Icons.face,
            isSelected: _accountType == AccountType.teen,
            onTap: () => setState(() => _accountType = AccountType.teen),
          ),
          const SizedBox(height: AppTheme.spacingXXL),
          ElevatedButton(
            onPressed: _accountType != null ? _nextPage : null,
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Tell us about yourself',
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'This helps Mindy personalize conversations',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingXXL),
          TextField(
            decoration: const InputDecoration(
              labelText: 'What should I call you? (optional)',
              hintText: 'Your name',
            ),
            onChanged: (value) => setState(() => _name = value),
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            'When were you born?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppTheme.spacingS),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() => _dateOfBirth = date);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(
                  color: AppTheme.textMuted.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: AppTheme.textMuted),
                  const SizedBox(width: AppTheme.spacingM),
                  Text(
                    _dateOfBirth != null
                        ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                        : 'Select date',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          if (_accountType == AccountType.teen) ...[
            const SizedBox(height: AppTheme.spacingL),
            Text(
              'Trusted adult contact (optional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              'This will only be used in a crisis situation',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Phone number or email',
                hintText: 'For crisis escalation only',
              ),
              onChanged: (value) =>
                  setState(() => _trustedAdultContact = value),
            ),
          ],
          const SizedBox(height: AppTheme.spacingXXL),
          ElevatedButton(
            onPressed: _nextPage,
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Your privacy matters',
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Mindy is GDPR-compliant and handles your data with care',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingXXL),
          _ConsentTile(
            title: 'Essential data storage',
            description:
                'Required for Mindy to function. Includes your conversations and preferences.',
            icon: Icons.storage,
            isRequired: true,
            isChecked: true,
          ),
          const SizedBox(height: AppTheme.spacingM),
          _ConsentTile(
            title: 'Personalized experience',
            description:
                'Allow Mindy to remember your context and preferences for better support.',
            icon: Icons.tune,
            isChecked: _consentPersonalized,
            onChanged: (value) =>
                setState(() => _consentPersonalized = value ?? false),
          ),
          const SizedBox(height: AppTheme.spacingM),
          _ConsentTile(
            title: 'Analytics (optional)',
            description:
                'Help improve Mindy by sharing anonymous usage insights.',
            icon: Icons.analytics_outlined,
            isChecked: _consentAnalytics,
            onChanged: (value) =>
                setState(() => _consentAnalytics = value ?? false),
          ),
          const SizedBox(height: AppTheme.spacingXXL),
          ElevatedButton(
            onPressed: _nextPage,
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'You\'re all set!',
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Here\'s what we\'ll remember',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingXXL),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              children: [
                _ReviewItem(
                  label: 'Account type',
                  value: _accountType == AccountType.adult ? 'Adult' : 'Teen',
                ),
                if (_name != null && _name!.isNotEmpty)
                  _ReviewItem(label: 'Name', value: _name!),
                if (_dateOfBirth != null)
                  _ReviewItem(
                    label: 'Birth date',
                    value:
                        '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}',
                  ),
                _ReviewItem(
                  label: 'Personalized experience',
                  value: _consentPersonalized ? 'Enabled' : 'Disabled',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingXL),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.primaryTeal),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Text(
                    'You can update your preferences anytime in Settings.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryTealDark,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingXXL),
          ElevatedButton(
            onPressed: _completeOnboarding,
            child: const Text('Start Your Journey'),
          ),
        ],
      ),
    );
  }
}

class _AccountTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccountTypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryTeal.withOpacity(0.1) : AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(
            color: isSelected ? AppTheme.primaryTeal : AppTheme.textMuted.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppTheme.softShadow : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryTeal
                    : AppTheme.textMuted.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppTheme.textMuted,
                size: 28,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? AppTheme.primaryTealDark
                              : AppTheme.textPrimary,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppTheme.primaryTeal,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}

class _ConsentTile extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isRequired;
  final bool isChecked;
  final ValueChanged<bool?>? onChanged;

  const _ConsentTile({
    required this.title,
    required this.description,
    required this.icon,
    this.isRequired = false,
    required this.isChecked,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
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
            child: Icon(icon, color: AppTheme.primaryTeal, size: 20),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (isRequired) ...[
                      const SizedBox(width: AppTheme.spacingXS),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTeal,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Required',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                      ),
                    ],
                  ],
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
          Switch(
            value: isChecked || isRequired,
            onChanged: isRequired ? null : onChanged,
            activeColor: AppTheme.primaryTeal,
          ),
        ],
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
