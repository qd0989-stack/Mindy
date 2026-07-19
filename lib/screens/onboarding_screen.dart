import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/user_model.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // Form data
  AccountType? _accountType;
  int _age = 20;
  String _name = '';
  CommunicationStyle _communicationStyle = CommunicationStyle.balanced;
  List<String> _stressors = [];
  bool _hasPriorTherapy = false;
  bool _disclaimerAccepted = false;
  String _trustedAdultName = '';
  String _trustedAdultContact = '';

  final List<String> _availableStressors = [
    'Work stress',
    'Relationship issues',
    'Family problems',
    'Academic pressure',
    'Financial concerns',
    'Health anxiety',
    'Sleep difficulties',
    'Loneliness',
    'Grief/loss',
    'Other',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      accountType: _accountType ?? AccountType.adult,
      age: _age,
      name: _name.isEmpty ? null : _name,
      communicationStyle: _communicationStyle,
      currentStressors: _stressors,
      hasPriorTherapy: _hasPriorTherapy,
      trustedAdultName: _trustedAdultName.isEmpty ? null : _trustedAdultName,
      trustedAdultContact: _trustedAdultContact.isEmpty ? null : _trustedAdultContact,
      disclaimerAccepted: _disclaimerAccepted,
    );
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Progress indicator
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: List.generate(5, (index) {
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: index <= _currentPage 
                              ? AppColors.primary 
                              : AppColors.textMuted.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              
              // Pages
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  children: [
                    _buildWelcomePage(),
                    _buildAccountTypePage(),
                    _buildPersonalInfoPage(),
                    _buildPreferencesPage(),
                    _buildDisclaimerPage(),
                  ],
                ),
              ),
              
              // Navigation buttons
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    if (_currentPage > 0)
                      TextButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text('Back'),
                      ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _canProceed() ? _nextPage : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      ),
                      child: Text(_currentPage == 4 ? 'Get Started' : 'Continue'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _canProceed() {
    switch (_currentPage) {
      case 0:
        return true;
      case 1:
        return _accountType != null;
      case 2:
        return _age >= 13;
      case 3:
        return true;
      case 4:
        return _disclaimerAccepted;
      default:
        return true;
    }
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(Icons.psychology, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 40),
          const Text(
            'Welcome to Mindy',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Your voice-activated psychological wellness companion',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.mic, color: AppColors.secondary),
                const SizedBox(width: 12),
                const Text(
                  'Just say "Hey Mindy" to start',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTypePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Who are you?',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'This helps us personalize your experience',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          _buildAccountTypeCard(
            type: AccountType.adult,
            title: 'Adult (20+)',
            description: 'I am 20 years or older',
            icon: Icons.person,
          ),
          const SizedBox(height: 16),
          _buildAccountTypeCard(
            type: AccountType.teen,
            title: 'Teen (Under 20)',
            description: 'I am under 20 years old',
            icon: Icons.child_care,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTypeCard({
    required AccountType type,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isSelected = _accountType == type;
    return GestureDetector(
      onTap: () => setState(() => _accountType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: isSelected ? Colors.white : AppColors.textMuted),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tell me about yourself',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'This helps Mindy support you better',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          
          // Age selector
          const Text('Your age', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _age = (_age - 1).clamp(13, 99)),
                icon: const Icon(Icons.remove_circle_outline),
                color: AppColors.primary,
              ),
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_age',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _age = (_age + 1).clamp(13, 99)),
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.primary,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Name field
          const Text('Your name (optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          TextField(
            onChanged: (value) => setState(() => _name = value),
            decoration: const InputDecoration(
              hintText: 'How should Mindy call you?',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          
          // Minor consent warning
          if (_age < 18) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.warning),
                      SizedBox(width: 8),
                      Text('Trusted Adult Contact', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.warning)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: (value) => setState(() => _trustedAdultName = value),
                    decoration: const InputDecoration(hintText: 'Name', filled: true),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    onChanged: (value) => setState(() => _trustedAdultContact = value),
                    decoration: const InputDecoration(hintText: 'Phone or Email', filled: true),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This contact will only be used for crisis escalation if you are in immediate danger.',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreferencesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your preferences',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Help us understand how to support you best',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          
          // Communication style
          const Text('Communication style', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: CommunicationStyle.values.map((style) {
              final isSelected = _communicationStyle == style;
              return ChoiceChip(
                label: Text(_getStyleName(style)),
                selected: isSelected,
                onSelected: (_) => setState(() => _communicationStyle = style),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surface,
                labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          
          // Stressors
          const Text('Current stressors', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          const Text('Select all that apply', style: TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableStressors.map((stressor) {
              final isSelected = _stressors.contains(stressor);
              return FilterChip(
                label: Text(stressor),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _stressors.add(stressor);
                    } else {
                      _stressors.remove(stressor);
                    }
                  });
                },
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surface,
                labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          
          // Prior therapy
          SwitchListTile(
            title: const Text('Have you had therapy before?', style: TextStyle(color: AppColors.textPrimary)),
            subtitle: const Text('This helps Mindy understand your experience', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            value: _hasPriorTherapy,
            onChanged: (value) => setState(() => _hasPriorTherapy = value),
            activeColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
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

  Widget _buildDisclaimerPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Important Information',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Disclaimer',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.warning),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Mindy is a wellness support tool. It doesn\'t replace a licensed therapist, doctor, or emergency services.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
                ),
                const SizedBox(height: 16),
                const Text(
                  'If you are in crisis or need immediate help, please contact:\n• Emergency: 112 (EU)\n• Crisis helpline in your country',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Privacy notice
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.security, color: AppColors.primary),
                    SizedBox(width: 12),
                    Text('Your Privacy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your conversations are encrypted and stored securely. You can delete your data at any time. Mindy is GDPR-compliant.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Agreement checkbox
          CheckboxListTile(
            value: _disclaimerAccepted,
            onChanged: (value) => setState(() => _disclaimerAccepted = value ?? false),
            title: const Text(
              'I understand and agree to the above terms',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            activeColor: AppColors.primary,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
