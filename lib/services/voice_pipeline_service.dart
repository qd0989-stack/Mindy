import 'dart:async';
import 'package:rxdart/rxdart.dart';
import '../domain/entities/memory.dart';
import '../domain/entities/user.dart';
import '../domain/entities/crisis_detection.dart';
import 'crisis_detection_service.dart';

/// Voice pipeline service abstraction
/// Supports streaming STT → LLM → TTS
abstract class VoicePipelineService {
  /// Stream of transcribed text from microphone
  Stream<String> get transcriptStream;

  /// Stream of Mindy's responses
  Stream<VoiceResponse> get responseStream;

  /// Stream of audio waveform data for visualization
  Stream<List<double>> get waveformStream;

  /// Start voice session
  Future<void> startSession({
    required String userId,
    required UserMemory? memory,
    required CommunicationStyle style,
  });

  /// Process user speech input
  Future<void> processSpeech(String transcript);

  /// End voice session
  Future<void> endSession();

  /// Pause/resume session
  Future<void> pauseSession();
  Future<void> resumeSession();

  /// Check if session is active
  bool get isSessionActive;

  /// Get current session duration
  Duration get sessionDuration;

  /// Dispose resources
  void dispose();
}

/// Voice response from Mindy
class VoiceResponse {
  final String text;
  final String? audioUrl; // For TTS playback
  final bool isWellbeingCheckpoint;
  final String? clinicalFramework; // CBT, ACT, DBT
  final bool hasCrisisRisk;
  final DateTime timestamp;

  const VoiceResponse({
    required this.text,
    this.audioUrl,
    this.isWellbeingCheckpoint = false,
    this.clinicalFramework,
    this.hasCrisisRisk = false,
    required this.timestamp,
  });
}

/// Session state for voice calls
enum VoiceSessionState {
  idle,
  listening,
  processing,
  speaking,
  paused,
  ended,
}

/// Demo implementation of voice pipeline
/// In production, this would connect to real STT/LLM/TTS services
class DemoVoicePipelineService implements VoicePipelineService {
  final CrisisDetectionService _crisisDetection;
  
  final _transcriptSubject = BehaviorSubject<String>();
  final _responseSubject = BehaviorSubject<VoiceResponse>();
  final _waveformSubject = BehaviorSubject<List<double>>();
  final _sessionStateSubject = BehaviorSubject<VoiceSessionState>();
  
  VoiceSessionState _state = VoiceSessionState.idle;
  DateTime? _sessionStartTime;
  Timer? _waveformTimer;
  Timer? _wellbeingTimer;
  int _checkpointCount = 0;

  DemoVoicePipelineService({CrisisDetectionService? crisisDetection})
      : _crisisDetection = crisisDetection ?? CrisisDetectionService();

  @override
  Stream<String> get transcriptStream => _transcriptSubject.stream;
  @override
  Stream<VoiceResponse> get responseStream => _responseSubject.stream;
  @override
  Stream<List<double>> get waveformStream => _waveformSubject.stream;
  Stream<VoiceSessionState> get stateStream => _sessionStateSubject.stream;

  @override
  bool get isSessionActive =>
      _state != VoiceSessionState.idle && _state != VoiceSessionState.ended;

  @override
  Duration get sessionDuration {
    if (_sessionStartTime == null) return Duration.zero;
    return DateTime.now().difference(_sessionStartTime!);
  }

  @override
  Future<void> startSession({
    required String userId,
    required UserMemory? memory,
    required CommunicationStyle style,
  }) async {
    _sessionStartTime = DateTime.now();
    _state = VoiceSessionState.listening;
    _sessionStateSubject.add(_state);
    _checkpointCount = 0;

    // Start waveform simulation
    _startWaveformSimulation();

    // Start wellbeing checkpoint timer
    _startWellbeingTimer();

    // Send initial greeting
    final greeting = _generateGreeting(memory, style);
    _responseSubject.add(VoiceResponse(
      text: greeting,
      timestamp: DateTime.now(),
    ));
  }

  String _generateGreeting(UserMemory? memory, CommunicationStyle style) {
    final hour = DateTime.now().hour;
    String timeGreeting;
    if (hour < 12) {
      timeGreeting = 'Good morning';
    } else if (hour < 17) {
      timeGreeting = 'Good afternoon';
    } else {
      timeGreeting = 'Good evening';
    }

    String stylePrefix = '';
    switch (style) {
      case CommunicationStyle.gentle:
        stylePrefix = 'I\'m here for you. ';
        break;
      case CommunicationStyle.direct:
        stylePrefix = 'Let\'s work through this together. ';
        break;
      case CommunicationStyle.balanced:
        stylePrefix = 'How can I support you today? ';
        break;
    }

    String memoryContext = '';
    if (memory != null && memory.recurringThemes.isNotEmpty) {
      final lastTheme = memory.recurringThemes.first.theme;
      memoryContext = ' Last time we talked about $lastTheme. ';
    }

    return '$timeGreeting! I\'m Mindy. '
        '$stylePrefix'
        '$memoryContext'
        'What\'s on your mind?';
  }

  @override
  Future<void> processSpeech(String transcript) async {
    if (_state == VoiceSessionState.paused) return;

    _transcriptSubject.add(transcript);
    _state = VoiceSessionState.processing;
    _sessionStateSubject.add(_state);

    // Check for crisis risk
    final crisisResult = _crisisDetection.detectRisk(transcript);

    if (crisisResult.hasRisk) {
      _state = VoiceSessionState.speaking;
      _sessionStateSubject.add(_state);

      final crisisResponse = _generateCrisisResponse(crisisResult);
      _responseSubject.add(crisisResponse);
      return;
    }

    // Simulate processing delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Generate response
    final response = _generateResponse(transcript);
    _state = VoiceSessionState.speaking;
    _sessionStateSubject.add(_state);
    _responseSubject.add(response);

    // Return to listening
    await Future.delayed(const Duration(seconds: 2));
    if (_state != VoiceSessionState.paused) {
      _state = VoiceSessionState.listening;
      _sessionStateSubject.add(_state);
    }
  }

  VoiceResponse _generateCrisisResponse(CrisisDetectionResult result) {
    final escalation = result.escalationLevel;
    final resources = _crisisDetection.getCrisisResources();

    String text;
    switch (escalation) {
      case CrisisEscalationLevel.immediate:
        text = 'I\'m concerned about what you\'ve shared. '
            'Your safety matters. Please contact emergency services (112) '
            'or the crisis helpline (${resources.first.phoneNumber}) '
            'right away. Is there someone nearby who can stay with you?';
      case CrisisEscalationLevel.high:
        text = 'I hear you, and I want you to know you\'re not alone. '
            'Please reach out to a crisis helpline: ${resources.first.phoneNumber}. '
            'If you\'re in immediate danger, call 112. '
            'Can you tell me who might be able to be with you right now?';
      case CrisisEscalationLevel.moderate:
        text = 'Thank you for sharing that with me. '
            'It sounds like things are really difficult right now. '
            'Have you considered talking to a professional or calling '
            '${resources.first.phoneNumber}? You deserve support.';
      case CrisisEscalationLevel.low:
        text = 'Thank you for opening up. '
            'It takes courage to talk about these things. '
            'I\'m here to listen. Would you like to explore this further?';
    }
    return VoiceResponse(
      text: text,
      hasCrisisRisk: true,
      timestamp: DateTime.now(),
    );
  }

  VoiceResponse _generateResponse(String transcript) {
    // This is a demo response generator
    // In production, this would call the actual LLM API
    final lower = transcript.toLowerCase();

    if (lower.contains('stressed') || lower.contains('anxious') || lower.contains('worried')) {
      return VoiceResponse(
        text: 'I hear that you\'re feeling stressed. '
            'Let\'s take a moment together. '
            'Can you tell me what\'s contributing to that stress? '
            'Sometimes naming the specific things can help us work through them.',
        clinicalFramework: 'CBT',
        timestamp: DateTime.now(),
      );
    }

    if (lower.contains('work') || lower.contains('job') || lower.contains('career')) {
      return VoiceResponse(
        text: 'Work can be a significant source of stress. '
            'What aspect of work is weighing on you most? '
            'Is it the workload, relationships with colleagues, or something else?',
        timestamp: DateTime.now(),
      );
    }

    if (lower.contains('sleep') || lower.contains('tired') || lower.contains('exhausted')) {
      return VoiceResponse(
        text: 'Sleep affects so much of how we feel. '
            'How would you describe your sleep lately? '
            'Sometimes small changes in our routine can make a difference.',
        timestamp: DateTime.now(),
      );
    }

    if (lower.contains('relationship') || lower.contains('partner') || lower.contains('family')) {
      return VoiceResponse(
        text: 'Relationships are complex and important. '
            'What\'s happening that you\'d like to process? '
            'I\'m here to listen without judgment.',
        timestamp: DateTime.now(),
      );
    }

    // Default supportive response
    return VoiceResponse(
      text: 'Thank you for sharing that with me. '
          'Tell me more about how that\'s been affecting you. '
          'What would feel most helpful right now?',
      timestamp: DateTime.now(),
    );
  }

  void _startWaveformSimulation() {
    _waveformTimer?.cancel();
    _waveformTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_state == VoiceSessionState.listening ||
          _state == VoiceSessionState.speaking) {
        final waveform = List.generate(
          32,
          (i) => 0.1 + (i % 4 == 0 ? 0.6 : 0.3) * (0.5 + (i.hashCode % 100) / 200),
        );
        _waveformSubject.add(waveform);
      } else {
        _waveformSubject.add(List.filled(32, 0.05));
      }
    });
  }

  void _startWellbeingTimer() {
    _wellbeingTimer?.cancel();
    // Check every 45 minutes (scaled down for demo: every 45 seconds)
    _wellbeingTimer = Timer.periodic(const Duration(seconds: 45), (timer) {
      if (isSessionActive && _state != VoiceSessionState.paused) {
        _checkpointCount++;
        _state = VoiceSessionState.speaking;
        _sessionStateSubject.add(_state);
        _responseSubject.add(VoiceResponse(
          text: 'I want to check in with you. '
              'We\'ve been talking for a while now. '
              'Would you like to continue, or shall we pick this up another time? '
              'There\'s no pressure either way.',
          isWellbeingCheckpoint: true,
          timestamp: DateTime.now(),
        ));
      }
    });
  }

  @override
  Future<void> endSession() async {
    _waveformTimer?.cancel();
    _wellbeingTimer?.cancel();
    _state = VoiceSessionState.ended;
    _sessionStateSubject.add(_state);
    _transcriptSubject.add('');
    await Future.delayed(const Duration(milliseconds: 500));
    _state = VoiceSessionState.idle;
    _sessionStateSubject.add(_state);
  }

  @override
  Future<void> pauseSession() async {
    _state = VoiceSessionState.paused;
    _sessionStateSubject.add(_state);
  }

  @override
  Future<void> resumeSession() async {
    _state = VoiceSessionState.listening;
    _sessionStateSubject.add(_state);
  }

  @override
  void dispose() {
    _waveformTimer?.cancel();
    _wellbeingTimer?.cancel();
    _transcriptSubject.close();
    _responseSubject.close();
    _waveformSubject.close();
    _sessionStateSubject.close();
  }
}
