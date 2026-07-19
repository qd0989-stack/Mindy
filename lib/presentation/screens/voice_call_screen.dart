import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/di/injection.dart';
import '../../services/voice_pipeline_service.dart';
import '../../services/personalization_engine.dart';
import '../../services/storage_service.dart';
import '../../services/crisis_detection_service.dart';
import '../../domain/entities/memory.dart';
import '../blocs/app_bloc.dart';
import '../blocs/voice_call_bloc.dart';
import '../widgets/waveform_widget.dart';
import '../widgets/crisis_resources_widget.dart';
import '../widgets/disclaimer_widget.dart';

/// Voice call screen with Mindy
class VoiceCallScreen extends StatefulWidget {
  const VoiceCallScreen({super.key});

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  late VoiceCallBloc _voiceCallBloc;
  List<double> _waveformData = List.filled(32, 0.1);
  String _currentTranscript = '';
  String _lastResponse = '';
  bool _showDisclaimer = true;
  bool _showCrisisResources = false;

  @override
  void initState() {
    super.initState();
    _voiceCallBloc = VoiceCallBloc(
      voicePipeline: getIt<DemoVoicePipelineService>(),
      personalization: PersonalizationEngine(getIt<StorageService>()),
    );
    _startCall();
  }

  @override
  void dispose() {
    _voiceCallBloc.close();
    super.dispose();
  }

  Future<void> _startCall() async {
    final appState = context.read<AppBloc>().state;
    if (appState is AppReady && appState.user != null) {
      final storage = getIt<StorageService>();
      final memory = await storage.getUserMemory();

      _voiceCallBloc.add(VoiceCallStart(
        odUserId: appState.user!.id,
        memory: memory,
        style: appState.user!.communicationStyle,
      ));
    }
  }

  void _endCall() {
    _voiceCallBloc.add(const VoiceCallEnd());
    context.pop();
  }

  void _pauseCall() {
    _voiceCallBloc.add(const VoiceCallPause());
  }

  void _resumeCall() {
    _voiceCallBloc.add(const VoiceCallResume());
  }

  void _simulateSpeech() {
    // Demo: simulate speech input
    final demoPhrases = [
      "I've been feeling really stressed about work lately",
      "My manager keeps piling on more tasks",
      "I'm having trouble sleeping",
      "I think I need to talk to someone about this",
      "Sometimes I feel like giving up",
    ];
    final phrase = demoPhrases[DateTime.now().second % demoPhrases.length];
    _voiceCallBloc.add(VoiceCallProcessSpeech(phrase));
    setState(() => _currentTranscript = phrase);
  }

  void _acknowledgeDisclaimer() {
    setState(() => _showDisclaimer = false);
  }

  void _handleCheckpointResponse(bool continueSession) {
    _voiceCallBloc.add(VoiceCallCheckpointResponded(continueSession));
    if (!continueSession) {
      _endCall();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _voiceCallBloc,
      child: BlocConsumer<VoiceCallBloc, VoiceCallState>(
        listener: (context, state) {
          if (state is VoiceCallActive) {
            if (state.isCrisisMode && !_showCrisisResources) {
              setState(() => _showCrisisResources = true);
            }
            if (state.lastResponse != null) {
              setState(() => _lastResponse = state.lastResponse!.text);
            }
          }
          if (state is VoiceCallEnded) {
            context.pop();
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppTheme.backgroundLight,
            body: SafeArea(
              child: _buildContent(context, state),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, VoiceCallState state) {
    if (state is VoiceCallConnecting) {
      return _buildConnectingState();
    }
    if (state is VoiceCallActive) {
      return _buildActiveState(context, state);
    }
    if (state is VoiceCallPaused) {
      return _buildPausedState(context, state);
    }
    if (state is VoiceCallError) {
      return _buildErrorState(context, state);
    }
    return _buildConnectingState();
  }

  Widget _buildConnectingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
                  spreadRadius: 5,
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
            'Connecting...',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'Setting up your session',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: AppTheme.spacingXXL),
          const CircularProgressIndicator(color: AppTheme.primaryTeal),
        ],
      ),
    );
  }

  Widget _buildActiveState(BuildContext context, VoiceCallActive state) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: _endCall,
                color: AppTheme.textSecondary,
              ),
              Column(
                children: [
                  Text(
                    'Mindy',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    _formatDuration(state.duration),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {},
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),

        // Disclaimer
        if (_showDisclaimer)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
            child: DisclaimerWidget(
              onAcknowledge: _acknowledgeDisclaimer,
              isCompact: true,
            ),
          ),

        const SizedBox(height: AppTheme.spacingL),

        // Crisis resources overlay
        if (_showCrisisResources)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: CrisisResourcesWidget(
                onCallEmergency: () {},
                onDismiss: () {
                  setState(() => _showCrisisResources = false);
                  _voiceCallBloc.add(const VoiceCallCrisisAcknowledged());
                },
              ),
            ),
          )
        else ...[
          // Waveform
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Status indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingM,
                      vertical: AppTheme.spacingS,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(state.sessionState)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getStatusColor(state.sessionState),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingS),
                        Text(
                          _getStatusText(state.sessionState),
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: _getStatusColor(state.sessionState),
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingXXL),

                  // Waveform visualization
                  StreamBuilder<List<double>>(
                    stream: getIt<DemoVoicePipelineService>().waveformStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        _waveformData = snapshot.data!;
                      }
                      return WaveformWidget(
                        waveformData: _waveformData,
                        isActive:
                            state.sessionState == VoiceSessionState.listening ||
                                state.sessionState == VoiceSessionState.speaking,
                      );
                    },
                  ),

                  const SizedBox(height: AppTheme.spacingXL),

                  // Transcript display
                  if (_currentTranscript.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingM),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceWhite,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.person, color: AppTheme.textMuted, size: 20),
                          const SizedBox(width: AppTheme.spacingS),
                          Expanded(
                            child: Text(
                              _currentTranscript,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Mindy's response
                  if (_lastResponse.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: AppTheme.spacingM),
                      padding: const EdgeInsets.all(AppTheme.spacingM),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryTeal,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.self_improvement,
                                color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: AppTheme.spacingS),
                          Expanded(
                            child: Text(
                              _lastResponse,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Wellbeing checkpoint
          if (state.isWellbeingCheckpointPending)
            _buildWellbeingCheckpoint(context),

          // Controls
          _buildControls(context, state),
        ],
      ],
    );
  }

  Widget _buildWellbeingCheckpoint(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingL),
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.mediumShadow,
      ),
      child: Column(
        children: [
          Icon(Icons.pause_circle_outline,
              color: AppTheme.primaryTeal, size: 48),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'Take a moment?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'We\'ve been talking for a while. Would you like to continue, or pick this up another time?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingL),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _handleCheckpointResponse(false),
                  child: const Text('End Session'),
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleCheckpointResponse(true),
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context, VoiceCallActive state) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Pause/Resume
          _ControlButton(
            icon: state.sessionState == VoiceSessionState.paused
                ? Icons.play_arrow
                : Icons.pause,
            label: state.sessionState == VoiceSessionState.paused
                ? 'Resume'
                : 'Pause',
            onPressed: state.sessionState == VoiceSessionState.paused
                ? _resumeCall
                : _pauseCall,
          ),

          // Demo: Simulate speech
          PulsingCircle(
            isPulsing: state.sessionState == VoiceSessionState.listening,
            color: AppTheme.primaryTeal,
            child: _ControlButton(
              icon: Icons.mic,
              label: 'Speak',
              isPrimary: true,
              onPressed: state.sessionState == VoiceSessionState.listening
                  ? _simulateSpeech
                  : null,
            ),
          ),

          // End call
          _ControlButton(
            icon: Icons.call_end,
            label: 'End',
            color: AppTheme.crisisRed,
            onPressed: _endCall,
          ),
        ],
      ),
    );
  }

  Widget _buildPausedState(BuildContext context, VoiceCallPaused state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pause_circle_outline,
            size: 80,
            color: AppTheme.primaryTeal,
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            'Session Paused',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'Duration: ${_formatDuration(state.duration)}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: AppTheme.spacingXL),
          ElevatedButton.icon(
            onPressed: _resumeCall,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Resume Session'),
          ),
          const SizedBox(height: AppTheme.spacingM),
          TextButton(
            onPressed: _endCall,
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, VoiceCallError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: AppTheme.error,
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            'Connection Error',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            state.message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingXL),
          ElevatedButton(
            onPressed: () {
              _startCall();
            },
            child: const Text('Try Again'),
          ),
          const SizedBox(height: AppTheme.spacingM),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Color _getStatusColor(VoiceSessionState sessionState) {
    switch (sessionState) {
      case VoiceSessionState.listening:
        return AppTheme.success;
      case VoiceSessionState.speaking:
        return AppTheme.primaryTeal;
      case VoiceSessionState.processing:
        return AppTheme.warning;
      case VoiceSessionState.paused:
        return AppTheme.textMuted;
      default:
        return AppTheme.textMuted;
    }
  }

  String _getStatusText(VoiceSessionState sessionState) {
    switch (sessionState) {
      case VoiceSessionState.listening:
        return 'Listening';
      case VoiceSessionState.speaking:
        return 'Speaking';
      case VoiceSessionState.processing:
        return 'Thinking...';
      case VoiceSessionState.paused:
        return 'Paused';
      default:
        return '';
    }
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final bool isPrimary;
  final VoidCallback? onPressed;

  const _ControlButton({
    required this.icon,
    required this.label,
    this.color,
    this.isPrimary = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppTheme.primaryTeal;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isPrimary ? 80 : 56,
            height: isPrimary ? 80 : 56,
            decoration: BoxDecoration(
              color: onPressed == null
                  ? effectiveColor.withOpacity(0.3)
                  : effectiveColor,
              shape: BoxShape.circle,
              boxShadow: isPrimary
                  ? [
                      BoxShadow(
                        color: effectiveColor.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: isPrimary ? 36 : 24,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: effectiveColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
