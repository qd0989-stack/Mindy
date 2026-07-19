import 'package:equatable/equatable.dart';

/// User memory for personalization engine
class UserMemory extends Equatable {
  final String odUserId;
  final List<MemoryEntry> entries;
  final List<RecurringTheme> recurringThemes;
  final List<CopingStrategyRecord> copingStrategiesHistory;
  final List<Goal> goals;
  final PersonalContext context;
  final DateTime lastUpdated;

  const UserMemory({
    required this.odUserId,
    this.entries = const [],
    this.recurringThemes = const [],
    this.copingStrategiesHistory = const [],
    this.goals = const [],
    required this.context,
    required this.lastUpdated,
  });

  /// Get a summary of the user's journey
  String getJourneySummary() {
    final recentThemes = recurringThemes.take(3).map((t) => t.theme).join(', ');
    final activeGoals = goals.where((g) => !g.isCompleted).length;
    return 'Recent themes: $recentThemes. Active goals: $activeGoals.';
  }

  /// Get the most effective coping strategies
  List<String> getEffectiveCopingStrategies() {
    return copingStrategiesHistory
        .where((s) => (s.effectivenessRating ?? 0) >= 3)
        .map((s) => s.strategy)
        .toSet()
        .take(5)
        .toList();
  }

  UserMemory copyWith({
    String? odUserId,
    List<MemoryEntry>? entries,
    List<RecurringTheme>? recurringThemes,
    List<CopingStrategyRecord>? copingStrategiesHistory,
    List<Goal>? goals,
    PersonalContext? context,
    DateTime? lastUpdated,
  }) {
    return UserMemory(
      odUserId: odUserId ?? this.odUserId,
      entries: entries ?? this.entries,
      recurringThemes: recurringThemes ?? this.recurringThemes,
      copingStrategiesHistory:
          copingStrategiesHistory ?? this.copingStrategiesHistory,
      goals: goals ?? this.goals,
      context: context ?? this.context,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        odUserId,
        entries,
        recurringThemes,
        copingStrategiesHistory,
        goals,
        context,
        lastUpdated,
      ];
}

/// A single memory entry
class MemoryEntry extends Equatable {
  final String id;
  final String content;
  final MemoryType type;
  final DateTime createdAt;
  final List<String> tags;
  final bool isPinned;
  final String? sessionId;

  const MemoryEntry({
    required this.id,
    required this.content,
    required this.type,
    required this.createdAt,
    this.tags = const [],
    this.isPinned = false,
    this.sessionId,
  });

  @override
  List<Object?> get props => [
        id,
        content,
        type,
        createdAt,
        tags,
        isPinned,
        sessionId,
      ];
}

/// Memory entry types
enum MemoryType {
  personalDetail, // Name, job, family info
  stressor, // Work, relationships, health
  achievement, // Wins, progress
  setback, // Challenges, difficulties
  copingStrategy, // What worked or didn't
  goal, // Future plans
  insight, // Self-reflections
  general, // Other
}

/// Recurring theme identified in conversations
class RecurringTheme extends Equatable {
  final String theme;
  final int occurrenceCount;
  final DateTime lastMentioned;
  final List<String> relatedMemories;
  final String? emotionalTone; // Positive, negative, neutral

  const RecurringTheme({
    required this.theme,
    required this.occurrenceCount,
    required this.lastMentioned,
    this.relatedMemories = const [],
    this.emotionalTone,
  });

  @override
  List<Object?> get props => [
        theme,
        occurrenceCount,
        lastMentioned,
        relatedMemories,
        emotionalTone,
      ];
}

/// Record of a coping strategy mentioned
class CopingStrategyRecord extends Equatable {
  final String strategy;
  final String sourceFramework; // CBT, ACT, DBT, etc.
  final DateTime mentionedAt;
  final String? sessionId;
  final int? effectivenessRating; // 1-5, null if not tried
  final String? outcomeNote;

  const CopingStrategyRecord({
    required this.strategy,
    required this.sourceFramework,
    required this.mentionedAt,
    this.sessionId,
    this.effectivenessRating,
    this.outcomeNote,
  });

  @override
  List<Object?> get props => [
        strategy,
        sourceFramework,
        mentionedAt,
        sessionId,
        effectivenessRating,
        outcomeNote,
      ];
}

/// Personal context for personalized responses
class PersonalContext extends Equatable {
  final String? occupation;
  final String? relationshipStatus;
  final String? livingSituation;
  final List<String> supportSystem; // Friends, family, professionals
  final bool hasPriorTherapy;
  final List<String> therapyTypes; // CBT, DBT, etc.
  final String sleepQuality; // Good, fair, poor
  final String workLifeBalance; // Good, fair, poor
  final List<String> hobbies;
  final String communicationStylePreference; // gentle, direct, balanced

  const PersonalContext({
    this.occupation,
    this.relationshipStatus,
    this.livingSituation,
    this.supportSystem = const [],
    this.hasPriorTherapy = false,
    this.therapyTypes = const [],
    this.sleepQuality = 'fair',
    this.workLifeBalance = 'fair',
    this.hobbies = const [],
    this.communicationStylePreference = 'balanced',
  });

  PersonalContext copyWith({
    String? occupation,
    String? relationshipStatus,
    String? livingSituation,
    List<String>? supportSystem,
    bool? hasPriorTherapy,
    List<String>? therapyTypes,
    String? sleepQuality,
    String? workLifeBalance,
    List<String>? hobbies,
    String? communicationStylePreference,
  }) {
    return PersonalContext(
      occupation: occupation ?? this.occupation,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      livingSituation: livingSituation ?? this.livingSituation,
      supportSystem: supportSystem ?? this.supportSystem,
      hasPriorTherapy: hasPriorTherapy ?? this.hasPriorTherapy,
      therapyTypes: therapyTypes ?? this.therapyTypes,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      workLifeBalance: workLifeBalance ?? this.workLifeBalance,
      hobbies: hobbies ?? this.hobbies,
      communicationStylePreference:
          communicationStylePreference ?? this.communicationStylePreference,
    );
  }

  @override
  List<Object?> get props => [
        occupation,
        relationshipStatus,
        livingSituation,
        supportSystem,
        hasPriorTherapy,
        therapyTypes,
        sleepQuality,
        workLifeBalance,
        hobbies,
        communicationStylePreference,
      ];
}

/// User goal
class Goal extends Equatable {
  final String id;
  final String title;
  final String? description;
  final GoalStatus status;
  final DateTime createdAt;
  final DateTime? targetDate;
  final List<String> milestones;
  final String? relatedTheme;

  const Goal({
    required this.id,
    required this.title,
    this.description,
    this.status = GoalStatus.active,
    required this.createdAt,
    this.targetDate,
    this.milestones = const [],
    this.relatedTheme,
  });

  bool get isCompleted => status == GoalStatus.completed;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        status,
        createdAt,
        targetDate,
        milestones,
        relatedTheme,
      ];
}

/// Goal status
enum GoalStatus { active, paused, completed, abandoned }
