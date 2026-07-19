import 'package:uuid/uuid.dart';
import '../domain/entities/memory.dart';
import '../domain/entities/session.dart';
import '../domain/entities/user.dart';
import 'storage_service.dart';

/// Personalization engine for Mindy
/// Manages user memory, recurring themes, and personalized responses
class PersonalizationEngine {
  final StorageService _storage;
  final Uuid _uuid = const Uuid();

  PersonalizationEngine(this._storage);

  /// Load or create user memory
  Future<UserMemory> getOrCreateMemory(String odUserId) async {
    final existing = await _storage.getUserMemory();
    if (existing != null && existing.odUserId == odUserId) {
      return existing;
    }

    // Create new memory
    final newMemory = UserMemory(
      odUserId: odUserId,
      entries: [],
      recurringThemes: [],
      copingStrategiesHistory: [],
      goals: [],
      context: const PersonalContext(),
      lastUpdated: DateTime.now(),
    );
    await _storage.saveUserMemory(newMemory);
    return newMemory;
  }

  /// Update memory with new information from conversation
  Future<UserMemory> updateMemory({
    required String odUserId,
    required List<SessionMessage> messages,
    String? contextUpdate,
  }) async {
    var memory = await getOrCreateMemory(odUserId);

    // Add new memory entries
    final newEntries = <MemoryEntry>[];
    for (final message in messages) {
      if (message.sender == MessageSender.user) {
        final entryType = _classifyMessageContent(message.content);
        newEntries.add(MemoryEntry(
          id: _uuid.v4(),
          content: message.content,
          type: entryType,
          createdAt: message.timestamp,
          sessionId: message.sessionId,
        ));
      }
    }

    // Update recurring themes
    final updatedThemes = _updateRecurringThemes(
      memory.recurringThemes,
      messages,
    );

    // Update coping strategies
    final updatedStrategies = _updateCopingStrategies(
      memory.copingStrategiesHistory,
      messages,
    );

    // Update context if provided
    PersonalContext updatedContext = memory.context;
    if (contextUpdate != null) {
      updatedContext = _parseContextUpdate(contextUpdate, memory.context);
    }

    memory = memory.copyWith(
      entries: [...memory.entries, ...newEntries],
      recurringThemes: updatedThemes,
      copingStrategiesHistory: updatedStrategies,
      context: updatedContext,
      lastUpdated: DateTime.now(),
    );

    await _storage.saveUserMemory(memory);
    return memory;
  }

  MemoryType _classifyMessageContent(String content) {
    final lower = content.toLowerCase();

    if (lower.contains('work') || lower.contains('job') || lower.contains('boss') || lower.contains('career')) {
      return MemoryType.stressor;
    }
    if (lower.contains('family') || lower.contains('parent') || lower.contains('kid') || lower.contains('spouse') || lower.contains('partner')) {
      return MemoryType.stressor;
    }
    if (lower.contains('achieve') || lower.contains('success') || lower.contains('proud') || lower.contains('won')) {
      return MemoryType.achievement;
    }
    if (lower.contains('sad') || lower.contains('depressed') || lower.contains('hopeless') || lower.contains('overwhelmed')) {
      return MemoryType.setback;
    }
    if (lower.contains('technique') || lower.contains('strategy') || lower.contains('coping') || lower.contains('helped')) {
      return MemoryType.copingStrategy;
    }
    if (lower.contains('goal') || lower.contains('plan') || lower.contains('want to') || lower.contains('will')) {
      return MemoryType.goal;
    }
    if (lower.contains('realized') || lower.contains('figured out') || lower.contains('understand')) {
      return MemoryType.insight;
    }

    return MemoryType.general;
  }

  List<RecurringTheme> _updateRecurringThemes(
    List<RecurringTheme> existing,
    List<SessionMessage> messages,
  ) {
    final themes = <String, int>{};

    for (final message in messages) {
      if (message.sender == MessageSender.user) {
        final extractedThemes = _extractThemes(message.content);
        for (final theme in extractedThemes) {
          themes[theme] = (themes[theme] ?? 0) + 1;
        }
      }
    }

    final now = DateTime.now();
    final updated = <RecurringTheme>[];

    for (final entry in existing) {
      if (themes.containsKey(entry.theme)) {
        themes.remove(entry.theme);
        updated.add(RecurringTheme(
          theme: entry.theme,
          occurrenceCount: entry.occurrenceCount + themes[entry.theme]!,
          lastMentioned: now,
          relatedMemories: entry.relatedMemories,
          emotionalTone: entry.emotionalTone,
        ));
      } else {
        updated.add(entry);
      }
    }

    // Add new themes
    for (final entry in themes.entries) {
      updated.add(RecurringTheme(
        theme: entry.key,
        occurrenceCount: entry.value,
        lastMentioned: now,
      ));
    }

    // Sort by occurrence and return top themes
    updated.sort((a, b) => b.occurrenceCount.compareTo(a.occurrenceCount));
    return updated.take(10).toList();
  }

  List<String> _extractThemes(String content) {
    // Simple keyword-based theme extraction
    // In production, this would use NLP
    final themes = <String>[];
    final lower = content.toLowerCase();

    if (lower.contains('work') || lower.contains('job')) {
      themes.add('work');
    }
    if (lower.contains('sleep') || lower.contains('rest')) {
      themes.add('sleep');
    }
    if (lower.contains('family') || lower.contains('parent')) {
      themes.add('family');
    }
    if (lower.contains('friend')) {
      themes.add('friends');
    }
    if (lower.contains('anxious') || lower.contains('anxiety')) {
      themes.add('anxiety');
    }
    if (lower.contains('stress') || lower.contains('stressed')) {
      themes.add('stress');
    }
    if (lower.contains('depress') || lower.contains('sad')) {
      themes.add('mood');
    }
    if (lower.contains('health')) {
      themes.add('health');
    }

    return themes;
  }

  List<CopingStrategyRecord> _updateCopingStrategies(
    List<CopingStrategyRecord> existing,
    List<SessionMessage> messages,
  ) {
    // Look for mentions of coping strategies in Mindy's responses
    // In production, this would parse structured strategy data from the LLM
    return existing;
  }

  PersonalContext _parseContextUpdate(String update, PersonalContext current) {
    // Parse natural language context updates
    final lower = update.toLowerCase();

    var occupation = current.occupation;
    var relationshipStatus = current.relationshipStatus;
    var sleepQuality = current.sleepQuality;
    var workLifeBalance = current.workLifeBalance;

    if (lower.contains('i work as') || lower.contains('i\'m a') || lower.contains('my job')) {
      // Extract occupation
      occupation = _extractValue(update, ['i work as', 'i\'m a', 'my job is']);
    }

    if (lower.contains('relationship') || lower.contains('married') || lower.contains('single')) {
      if (lower.contains('married')) relationshipStatus = 'married';
      if (lower.contains('single')) relationshipStatus = 'single';
      if (lower.contains('relationship')) relationshipStatus = 'in relationship';
    }

    if (lower.contains('sleep well') || lower.contains('sleeping well')) {
      sleepQuality = 'good';
    } else if (lower.contains('sleep poorly') || lower.contains('tired')) {
      sleepQuality = 'poor';
    }

    if (lower.contains('good balance') || lower.contains('balanced')) {
      workLifeBalance = 'good';
    } else if (lower.contains('unbalanced') || lower.contains('overworked')) {
      workLifeBalance = 'poor';
    }

    return current.copyWith(
      occupation: occupation,
      relationshipStatus: relationshipStatus,
      sleepQuality: sleepQuality,
      workLifeBalance: workLifeBalance,
    );
  }

  String? _extractValue(String text, List<String> prefixes) {
    for (final prefix in prefixes) {
      final index = text.toLowerCase().indexOf(prefix);
      if (index != -1) {
        final start = index + prefix.length;
        final end = text.indexOf('.', start);
        if (end != -1) {
          return text.substring(start, end).trim();
        }
      }
    }
    return null;
  }

  /// Generate personalized prompt context for the LLM
  String generatePromptContext(UserMemory memory, CommunicationStyle style) {
    final buffer = StringBuffer();

    // Recent themes
    if (memory.recurringThemes.isNotEmpty) {
      buffer.writeln('Recent themes: ${memory.recurringThemes.take(3).map((t) => t.theme).join(', ')}.');
    }

    // Active goals
    final activeGoals = memory.goals.where((g) => !g.isCompleted);
    if (activeGoals.isNotEmpty) {
      buffer.writeln('Active goals: ${activeGoals.take(2).map((g) => g.title).join(', ')}.');
    }

    // What worked before
    final effectiveStrategies = memory.getEffectiveCopingStrategies();
    if (effectiveStrategies.isNotEmpty) {
      buffer.writeln('Previously effective strategies: ${effectiveStrategies.join(', ')}.');
    }

    // Communication style
    buffer.writeln('Communication style: ${style.name}.');

    // Context
    if (memory.context.occupation != null) {
      buffer.writeln('User is a ${memory.context.occupation}.');
    }

    return buffer.toString();
  }

  /// Add a goal
  Future<UserMemory> addGoal({
    required String odUserId,
    required String title,
    String? description,
    DateTime? targetDate,
  }) async {
    final memory = await getOrCreateMemory(odUserId);

    final goal = Goal(
      id: _uuid.v4(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      targetDate: targetDate,
    );

    final updatedMemory = memory.copyWith(
      goals: [...memory.goals, goal],
      lastUpdated: DateTime.now(),
    );

    await _storage.saveUserMemory(updatedMemory);
    return updatedMemory;
  }

  /// Update goal status
  Future<UserMemory> updateGoalStatus({
    required String odUserId,
    required String goalId,
    required GoalStatus status,
  }) async {
    final memory = await getOrCreateMemory(odUserId);

    final updatedGoals = memory.goals.map((g) {
      if (g.id == goalId) {
        return Goal(
          id: g.id,
          title: g.title,
          description: g.description,
          status: status,
          createdAt: g.createdAt,
          targetDate: g.targetDate,
          milestones: g.milestones,
          relatedTheme: g.relatedTheme,
        );
      }
      return g;
    }).toList();

    final updatedMemory = memory.copyWith(
      goals: updatedGoals,
      lastUpdated: DateTime.now(),
    );

    await _storage.saveUserMemory(updatedMemory);
    return updatedMemory;
  }

  /// Add memory entry
  Future<UserMemory> addMemoryEntry({
    required String odUserId,
    required String content,
    MemoryType type = MemoryType.general,
    bool isPinned = false,
  }) async {
    final memory = await getOrCreateMemory(odUserId);

    final entry = MemoryEntry(
      id: _uuid.v4(),
      content: content,
      type: type,
      createdAt: DateTime.now(),
      isPinned: isPinned,
    );

    final updatedMemory = memory.copyWith(
      entries: [...memory.entries, entry],
      lastUpdated: DateTime.now(),
    );

    await _storage.saveUserMemory(updatedMemory);
    return updatedMemory;
  }

  /// Generate session summary for context compaction
  SessionSummary generateSessionSummary(List<SessionMessage> messages) {
    final keyThemes = <String>[];
    final strategiesMentioned = <String>[];
    final actionItems = <String>[];

    for (final message in messages) {
      final themes = _extractThemes(message.content);
      keyThemes.addAll(themes);
    }

    return SessionSummary(
      summary: 'Session covered: ${keyThemes.take(5).join(', ')}.',
      keyThemes: keyThemes.toSet().take(5).toList(),
      copingStrategiesMentioned: strategiesMentioned,
      actionItems: actionItems,
      generatedAt: DateTime.now(),
    );
  }
}
