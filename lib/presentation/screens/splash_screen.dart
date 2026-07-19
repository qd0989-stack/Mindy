import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../blocs/app_bloc.dart';
import '../widgets/disclaimer_widget.dart';

/// Splash screen with disclaimer
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDisclaimerAcknowledge() {
    context.read<AppBloc>().add(const AppDisclaimerAcknowledged());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppBloc, AppState>(
      listener: (context, state) {
        if (state is AppReady) {
          if (state.isOnboarded) {
            context.go('/home');
          } else if (state.hasUser) {
            context.go('/onboarding');
          } else {
            context.go('/onboarding');
          }
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.surfaceWhite,
                AppTheme.primaryTealLight.withOpacity(0.3),
                AppTheme.accentLavenderLight.withOpacity(0.2),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),
                          // Logo
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryTeal.withOpacity(0.3),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.self_improvement,
                              color: Colors.white,
                              size: 60,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingXL),
                          Text(
                            'Mindy',
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(
                                  color: AppTheme.primaryTealDark,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: AppTheme.spacingS),
                          Text(
                            'Your wellness companion',
                            style:
                                Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                          ),
                          const Spacer(),
                          // Disclaimer
                          DisclaimerWidget(
                            onAcknowledge: _handleDisclaimerAcknowledge,
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
