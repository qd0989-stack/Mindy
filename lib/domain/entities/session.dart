import 'package:equatable/equatable.dart';

/// Session type
enum SessionType { voiceCall, textChat }

/// Session status
enum SessionStatus {
  active,
  paused,
  resumed,
  completed,
  dropped,
  crisisTriggered,
}

/// Voice session entity
class Session extends Equatable {
  final String id;
  final String odUserId;
  final SessionType type;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? duration;
  final SessionStatus status;
  final List<SessionMessage> messages;
  final SessionSummary? summary;
  final int wellbeingCheckpointCount;

  const Session({
    required this.id,
    required this.odUserId,
    required this.type,
    required this.startTime,
    this.endTime,
    this.duration,
    required this.status,
    this.messages = const [],
    this.summary,
    this.wellbeingCheckpointCount = 0,
  });

  /// Check if session is long enough to require wellbeing checkpoint
  bool get needsWellbeingCheckpoint {
    if (duration == null) return false;
    return duration!.inMinutes >= 45 &&
        wellbeingCheckpointCount == 0;
  }

  /// Get session summary for context compaction
  String get compactSummary {
    if (summary != null) {
      return summary!.summary;
    }
    // Generate a basic summary from messages
    if (messages.isEmpty) return '';
    final recentMessages = messages.take(5).map((m) => m.content).join(' ');
    return recentMessages.length > 200
        ? '${recentMessages.substring(0, 200)}...'
        : recentMessages;
  }

  Session copyWith({
    String? id,
    String? odUserId,
    SessionType? type,
    DateTime? startTime,
    DateTime? endTime,
    Duration? duration,
    SessionStatus? status,
    List<SessionMessage>? messages,
    SessionSummary? summary,
    int? wellbeingCheckpointCount,
  }) {
    return Session(
      id: id ?? this.id,
      odUserId: odUserId ?? this.odUserId,
      type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      messages: messages ?? this.messages,
      summary: summary ?? this.summary,
      wellbeingCheckpointCount:
          wellbeingCheckpointCount ?? this.wellbeingCheckpointCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        odUserId,
        type,
        startTime,
        endTime,
        duration,
        status,
        messages,
        summary,
        wellbeingCheckpointCount,
      ];
}

/// Message within a session
class SessionMessage extends Equatable {
  final String id;
  final String sessionId;
  final String content;
  final MessageSender sender;
  final DateTime timestamp;
  final bool hasCrisisRisk;
  final CrisisRiskLevel? crisisRiskLevel;
  final String? clinicalFramework; // CBT, ACT, DBT, etc.

  const SessionMessage({
    required this.id,
    required this.sessionId,
    required this.content,
    required this.sender,
    required this.timestamp,
    this.hasCrisisRisk = false,
    this.crisisRiskLevel,
    this.clinicalFramework,
  });

  SessionMessage copyWith({
    String? id,
    String? sessionId,
    String? content,
    MessageSender? sender,
    DateTime? timestamp,
    bool? hasCrisisRisk,
    CrisisRiskLevel? crisisRiskLevel,
    String? clinicalFramework,
  }) {
    return SessionMessage(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      content: content ?? this.content,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      hasCrisisRisk: hasCrisisRisk ?? this.hasCrisisRisk,
      crisisRiskLevel: crisisRiskLevel ?? this.crisisRiskLevel,
      clinicalFramework: clinicalFramework ?? this.clinicalFramework,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sessionId,
        content,
        sender,
        timestamp,
        hasCrisisRisk,
        crisisRiskLevel,
        clinicalFramework,
      ];
}

/// Message sender
enum MessageSender { user, mindy }

/// Crisis risk level
enum CrisisRiskLevel { low, medium, high, critical }

/// Session summary for context compaction
class SessionSummary extends Equatable {
  final String summary;
  final List<String> keyThemes;
  final List<String> copingStrategiesMentioned;
  final List<String> actionItems;
  final DateTime generatedAt;

  const SessionSummary({
    required this.summary,
    this.keyThemes = const [],
    this.copingStrategiesMentioned = const [],
    this.actionItems = const [],
    required this.generatedAt,
  });

  @override
  List<Object?> get props => [
        summary,
        keyThemes,
        copingStrategiesMentioned,
        actionItems,
        generatedAt,
      ];
}
