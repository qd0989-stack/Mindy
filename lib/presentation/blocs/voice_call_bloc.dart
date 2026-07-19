import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/memory.dart';
import '../../domain/entities/session.dart';
import '../../domain/entities/user.dart';
import '../../services/voice_pipeline_service.dart';
import '../../services/personalization_engine.dart';

// Events
abstract class VoiceCallEvent extends Equatable {
  const VoiceCallEvent();

  @override
  List<Object?> get props => [];
}

class VoiceCallStart extends VoiceCallEvent {
  final String odUserId;
  final UserMemory? memory;
  final CommunicationStyle style;
  const VoiceCallStart({
    required this.odUserId,
    this.memory,
    this.style = CommunicationStyle.gentle,
  });

  @override
  List<Object?> get props => [odUserId, memory, style];
}

class VoiceCallEnd extends VoiceCallEvent {
  const VoiceCallEnd();
}

class VoiceCallPause extends VoiceCallEvent {
  const VoiceCallPause();
}

class VoiceCallResume extends VoiceCallEvent {
  const VoiceCallResume();
}

class VoiceCallProcessSpeech extends VoiceCallEvent {
  final String transcript;
  const VoiceCallProcessSpeech(this.transcript);

  @override
  List<Object?> get props => [transcript];
}

class VoiceCallMessageReceived extends VoiceCallEvent {
  final VoiceResponse response;
  const VoiceCallMessageReceived(this.response);

  @override
  List<Object?> get props => [response];
}

class VoiceCallWellbeingCheckpoint extends VoiceCallEvent {
  const VoiceCallWellbeingCheckpoint();
}

class VoiceCallCheckpointResponded extends VoiceCallEvent {
  final bool continueSession;
  const VoiceCallCheckpointResponded(this.continueSession);

  @override
  List<Object?> get props => [continueSession];
}

class VoiceCallCrisisDetected extends VoiceCallEvent {
  final VoiceResponse response;
  const VoiceCallCrisisDetected(this.response);

  @override
  List<Object?> get props => [response];
}

class VoiceCallCrisisAcknowledged extends VoiceCallEvent {
  const VoiceCallCrisisAcknowledged();
}

// States
abstract class VoiceCallState extends Equatable {
  const VoiceCallState();

  @override
  List<Object?> get props => [];
}

class VoiceCallIdle extends VoiceCallState {
  const VoiceCallIdle();
}

class VoiceCallConnecting extends VoiceCallState {
  const VoiceCallConnecting();
}

class VoiceCallActive extends VoiceCallState {
  final Duration duration;
  final List<SessionMessage> messages;
  final bool isWellbeingCheckpointPending;
  final bool isCrisisMode;
  final VoiceResponse? lastResponse;
  final VoiceSessionState sessionState;

  const VoiceCallActive({
    this.duration = Duration.zero,
    this.messages = const [],
    this.isWellbeingCheckpointPending = false,
    this.isCrisisMode = false,
    this.lastResponse,
    this.sessionState = VoiceSessionState.listening,
  });

  @override
  List<Object?> get props => [
        duration,
        messages,
        isWellbeingCheckpointPending,
        isCrisisMode,
        lastResponse,
        sessionState,
      ];

  VoiceCallActive copyWith({
    Duration? duration,
    List<SessionMessage>? messages,
    bool? isWellbeingCheckpointPending,
    bool? isCrisisMode,
    VoiceResponse? lastResponse,
    VoiceSessionState? sessionState,
  }) {
    return VoiceCallActive(
      duration: duration ?? this.duration,
      messages: messages ?? this.messages,
      isWellbeingCheckpointPending:
          isWellbeingCheckpointPending ?? this.isWellbeingCheckpointPending,
      isCrisisMode: isCrisisMode ?? this.isCrisisMode,
      lastResponse: lastResponse ?? this.lastResponse,
      sessionState: sessionState ?? this.sessionState,
    );
  }
}

class VoiceCallPaused extends VoiceCallState {
  final Duration duration;
  const VoiceCallPaused(this.duration);

  @override
  List<Object?> get props => [duration];
}

class VoiceCallEnded extends VoiceCallState {
  final Duration duration;
  final List<SessionMessage> messages;
  final SessionSummary? summary;

  const VoiceCallEnded({
    required this.duration,
    this.messages = const [],
    this.summary,
  });

  @override
  List<Object?> get props => [duration, messages, summary];
}

class VoiceCallError extends VoiceCallState {
  final String message;
  const VoiceCallError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class VoiceCallBloc extends Bloc<VoiceCallEvent, VoiceCallState> {
  final DemoVoicePipelineService _voicePipeline;
  final PersonalizationEngine _personalization;

  StreamSubscription<VoiceResponse>? _responseSubscription;
  StreamSubscription<VoiceSessionState>? _stateSubscription;
  Timer? _durationTimer;
  String? _currentSessionId;
  List<SessionMessage> _messages = [];

  VoiceCallBloc({
    required DemoVoicePipelineService voicePipeline,
    required PersonalizationEngine personalization,
  })  : _voicePipeline = voicePipeline,
        _personalization = personalization,
        super(const VoiceCallIdle()) {
    on<VoiceCallStart>(_onStart);
    on<VoiceCallEnd>(_onEnd);
    on<VoiceCallPause>(_onPause);
    on<VoiceCallResume>(_onResume);
    on<VoiceCallProcessSpeech>(_onProcessSpeech);
    on<VoiceCallMessageReceived>(_onMessageReceived);
    on<VoiceCallWellbeingCheckpoint>(_onWellbeingCheckpoint);
    on<VoiceCallCheckpointResponded>(_onCheckpointResponded);
    on<VoiceCallCrisisDetected>(_onCrisisDetected);
    on<VoiceCallCrisisAcknowledged>(_onCrisisAcknowledged);
  }

  Future<void> _onStart(
    VoiceCallStart event,
    Emitter<VoiceCallState> emit,
  ) async {
    emit(const VoiceCallConnecting());
    _messages = [];
    _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      await _voicePipeline.startSession(
        userId: event.odUserId,
        memory: event.memory,
        style: event.style,
      );

      // Listen for responses
      _responseSubscription = _voicePipeline.responseStream.listen((response) {
        if (response.hasCrisisRisk) {
          add(VoiceCallCrisisDetected(response));
        } else if (response.isWellbeingCheckpoint) {
          add(const VoiceCallWellbeingCheckpoint());
        } else {
          add(VoiceCallMessageReceived(response));
        }
      });

      // Listen for state changes
      _stateSubscription = _voicePipeline.stateStream.listen((sessionState) {
        final currentState = state;
        if (currentState is VoiceCallActive) {
          emit(currentState.copyWith(sessionState: sessionState));
        }
      });

      // Start duration timer
      _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        final currentState = state;
        if (currentState is VoiceCallActive && !currentState.isCrisisMode) {
          emit(currentState.copyWith(
            duration: _voicePipeline.sessionDuration,
          ));
        }
      });

      emit(const VoiceCallActive(
        sessionState: VoiceSessionState.listening,
      ));
    } catch (e) {
      emit(VoiceCallError(e.toString()));
    }
  }

  Future<void> _onEnd(
    VoiceCallEnd event,
    Emitter<VoiceCallState> emit,
  ) async {
    _durationTimer?.cancel();
    _responseSubscription?.cancel();
    _stateSubscription?.cancel();

    await _voicePipeline.endSession();

    final summary = _personalization.generateSessionSummary(_messages);

    emit(VoiceCallEnded(
      duration: _voicePipeline.sessionDuration,
      messages: _messages,
      summary: summary,
    ));

    await Future.delayed(const Duration(seconds: 1));
    emit(const VoiceCallIdle());
  }

  Future<void> _onPause(
    VoiceCallPause event,
    Emitter<VoiceCallState> emit,
  ) async {
    await _voicePipeline.pauseSession();
    final currentState = state;
    if (currentState is VoiceCallActive) {
      emit(VoiceCallPaused(currentState.duration));
    }
  }

  Future<void> _onResume(
    VoiceCallResume event,
    Emitter<VoiceCallState> emit,
  ) async {
    await _voicePipeline.resumeSession();
    final currentState = state;
    if (currentState is VoiceCallPaused) {
      emit(VoiceCallActive(
        duration: currentState.duration,
        sessionState: VoiceSessionState.listening,
      ));
    }
  }

  Future<void> _onProcessSpeech(
    VoiceCallProcessSpeech event,
    Emitter<VoiceCallState> emit,
  ) async {
    // Add user message to history
    final userMessage = SessionMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: _currentSessionId ?? '',
      content: event.transcript,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);

    await _voicePipeline.processSpeech(event.transcript);
  }

  void _onMessageReceived(
    VoiceCallMessageReceived event,
    Emitter<VoiceCallState> emit,
  ) {
    // Add Mindy's response to history
    final mindyMessage = SessionMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: _currentSessionId ?? '',
      content: event.response.text,
      sender: MessageSender.mindy,
      timestamp: DateTime.now(),
      clinicalFramework: event.response.clinicalFramework,
    );
    _messages.add(mindyMessage);

    final currentState = state;
    if (currentState is VoiceCallActive) {
      emit(currentState.copyWith(
        messages: List.from(_messages),
        lastResponse: event.response,
      ));
    }
  }

  void _onWellbeingCheckpoint(
    VoiceCallWellbeingCheckpoint event,
    Emitter<VoiceCallState> emit,
  ) {
    final currentState = state;
    if (currentState is VoiceCallActive) {
      emit(currentState.copyWith(isWellbeingCheckpointPending: true));
    }
  }

  Future<void> _onCheckpointResponded(
    VoiceCallCheckpointResponded event,
    Emitter<VoiceCallState> emit,
  ) async {
    final currentState = state;
    if (currentState is VoiceCallActive) {
      emit(currentState.copyWith(isWellbeingCheckpointPending: false));

      if (!event.continueSession) {
        add(const VoiceCallEnd());
      }
    }
  }

  void _onCrisisDetected(
    VoiceCallCrisisDetected event,
    Emitter<VoiceCallState> emit,
  ) {
    final currentState = state;
    if (currentState is VoiceCallActive) {
      // Add crisis response to messages
      final mindyMessage = SessionMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sessionId: _currentSessionId ?? '',
        content: event.response.text,
        sender: MessageSender.mindy,
        timestamp: DateTime.now(),
        hasCrisisRisk: true,
      );
      _messages.add(mindyMessage);

      emit(currentState.copyWith(
        messages: List.from(_messages),
        isCrisisMode: true,
        lastResponse: event.response,
      ));
    }
  }

  void _onCrisisAcknowledged(
    VoiceCallCrisisAcknowledged event,
    Emitter<VoiceCallState> emit,
  ) {
    final currentState = state;
    if (currentState is VoiceCallActive) {
      emit(currentState.copyWith(isCrisisMode: false));
    }
  }

  @override
  Future<void> close() {
    _durationTimer?.cancel();
    _responseSubscription?.cancel();
    _stateSubscription?.cancel();
    return super.close();
  }
}
