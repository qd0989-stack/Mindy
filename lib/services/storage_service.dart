import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/entities/entities.dart';

/// Service for secure data storage
/// Handles encryption and GDPR compliance
class StorageService {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  static const String _keyUserProfile = 'user_profile';
  static const String _keyConsentRecord = 'consent_record';
  static const String _keyUserMemory = 'user_memory';
  static const String _keyCrisisLogs = 'crisis_logs';
  static const String _keyDisclaimerAcknowledged = 'disclaimer_acknowledged';
  static const String _keyOnboardingComplete = 'onboarding_complete';

  StorageService({
    FlutterSecureStorage? secureStorage,
    required SharedPreferences prefs,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock_this_device,
          ),
        ),
        _prefs = prefs;

  // User Profile

  Future<void> saveUserProfile(User user) async {
    final json = jsonEncode({
      'id': user.id,
      'name': user.name,
      'dateOfBirth': user.dateOfBirth?.toIso8601String(),
      'accountType': user.accountType.name,
      'subscriptionStatus': user.subscriptionStatus.name,
      'trustedAdultContact': user.trustedAdultContact,
      'communicationStyle': user.communicationStyle.name,
      'createdAt': user.createdAt.toIso8601String(),
      'lastActiveAt': user.lastActiveAt?.toIso8601String(),
    });
    await _secureStorage.write(key: _keyUserProfile, value: json);
  }

  Future<User?> getUserProfile() async {
    final json = await _secureStorage.read(key: _keyUserProfile);
    if (json == null) return null;

    final map = jsonDecode(json) as Map<String, dynamic>;
    return User(
      id: map['id'] as String,
      name: map['name'] as String?,
      dateOfBirth: map['dateOfBirth'] != null
          ? DateTime.parse(map['dateOfBirth'] as String)
          : null,
      accountType: AccountType.values.firstWhere(
        (e) => e.name == map['accountType'],
        orElse: () => AccountType.adult,
      ),
      subscriptionStatus: SubscriptionStatus.values.firstWhere(
        (e) => e.name == map['subscriptionStatus'],
        orElse: () => SubscriptionStatus.free,
      ),
      trustedAdultContact: map['trustedAdultContact'] as String?,
      communicationStyle: CommunicationStyle.values.firstWhere(
        (e) => e.name == map['communicationStyle'],
        orElse: () => CommunicationStyle.gentle,
      ),
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastActiveAt: map['lastActiveAt'] != null
          ? DateTime.parse(map['lastActiveAt'] as String)
          : null,
    );
  }

  Future<void> deleteUserProfile() async {
    await _secureStorage.delete(key: _keyUserProfile);
  }

  // Consent Record

  Future<void> saveConsentRecord(ConsentRecord record) async {
    final json = jsonEncode({
      'id': record.id,
      'odUserId': record.odUserId,
      'consents': record.consents.map((c) => {
        'type': c.type.name,
        'isGranted': c.isGranted,
        'recordedAt': c.recordedAt?.toIso8601String(),
        'version': c.version,
      }).toList(),
      'recordedAt': record.recordedAt.toIso8601String(),
      'guardianConsentId': record.guardianConsentId,
      'guardianConsentDate': record.guardianConsentDate?.toIso8601String(),
    });
    await _secureStorage.write(key: _keyConsentRecord, value: json);
  }

  Future<ConsentRecord?> getConsentRecord() async {
    final json = await _secureStorage.read(key: _keyConsentRecord);
    if (json == null) return null;

    final map = jsonDecode(json) as Map<String, dynamic>;
    return ConsentRecord(
      id: map['id'] as String,
      odUserId: map['odUserId'] as String,
      consents: (map['consents'] as List)
          .map((c) => ConsentItem(
                type: ConsentType.values.firstWhere(
                  (e) => e.name == c['type'],
                  orElse: () => ConsentType.essential,
                ),
                isGranted: c['isGranted'] as bool,
                recordedAt: c['recordedAt'] != null
                    ? DateTime.parse(c['recordedAt'] as String)
                    : null,
                version: c['version'] as String?,
              ))
          .toList(),
      recordedAt: DateTime.parse(map['recordedAt'] as String),
      guardianConsentId: map['guardianConsentId'] as String?,
      guardianConsentDate: map['guardianConsentDate'] != null
          ? DateTime.parse(map['guardianConsentDate'] as String)
          : null,
    );
  }

  // User Memory

  Future<void> saveUserMemory(UserMemory memory) async {
    final json = jsonEncode({
      'odUserId': memory.odUserId,
      'entries': memory.entries.map((e) => {
        'id': e.id,
        'content': e.content,
        'type': e.type.name,
        'createdAt': e.createdAt.toIso8601String(),
        'tags': e.tags,
        'isPinned': e.isPinned,
        'sessionId': e.sessionId,
      }).toList(),
      'recurringThemes': memory.recurringThemes.map((t) => {
        'theme': t.theme,
        'occurrenceCount': t.occurrenceCount,
        'lastMentioned': t.lastMentioned.toIso8601String(),
        'relatedMemories': t.relatedMemories,
        'emotionalTone': t.emotionalTone,
      }).toList(),
      'goals': memory.goals.map((g) => {
        'id': g.id,
        'title': g.title,
        'description': g.description,
        'status': g.status.name,
        'createdAt': g.createdAt.toIso8601String(),
        'targetDate': g.targetDate?.toIso8601String(),
        'milestones': g.milestones,
        'relatedTheme': g.relatedTheme,
      }).toList(),
      'context': {
        'occupation': memory.context.occupation,
        'relationshipStatus': memory.context.relationshipStatus,
        'livingSituation': memory.context.livingSituation,
        'supportSystem': memory.context.supportSystem,
        'hasPriorTherapy': memory.context.hasPriorTherapy,
        'therapyTypes': memory.context.therapyTypes,
        'sleepQuality': memory.context.sleepQuality,
        'workLifeBalance': memory.context.workLifeBalance,
        'hobbies': memory.context.hobbies,
        'communicationStylePreference': memory.context.communicationStylePreference,
      },
      'lastUpdated': memory.lastUpdated.toIso8601String(),
    });
    await _secureStorage.write(key: _keyUserMemory, value: json);
  }

  Future<UserMemory?> getUserMemory() async {
    final json = await _secureStorage.read(key: _keyUserMemory);
    if (json == null) return null;

    final map = jsonDecode(json) as Map<String, dynamic>;
    return UserMemory(
      odUserId: map['odUserId'] as String,
      entries: (map['entries'] as List)
          .map((e) => MemoryEntry(
                id: e['id'] as String,
                content: e['content'] as String,
                type: MemoryType.values.firstWhere(
                  (t) => t.name == e['type'],
                  orElse: () => MemoryType.general,
                ),
                createdAt: DateTime.parse(e['createdAt'] as String),
                tags: List<String>.from(e['tags'] ?? []),
                isPinned: e['isPinned'] as bool? ?? false,
                sessionId: e['sessionId'] as String?,
              ))
          .toList(),
      recurringThemes: (map['recurringThemes'] as List)
          .map((t) => RecurringTheme(
                theme: t['theme'] as String,
                occurrenceCount: t['occurrenceCount'] as int,
                lastMentioned: DateTime.parse(t['lastMentioned'] as String),
                relatedMemories: List<String>.from(t['relatedMemories'] ?? []),
                emotionalTone: t['emotionalTone'] as String?,
              ))
          .toList(),
      goals: (map['goals'] as List)
          .map((g) => Goal(
                id: g['id'] as String,
                title: g['title'] as String,
                description: g['description'] as String?,
                status: GoalStatus.values.firstWhere(
                  (s) => s.name == g['status'],
                  orElse: () => GoalStatus.active,
                ),
                createdAt: DateTime.parse(g['createdAt'] as String),
                targetDate: g['targetDate'] != null
                    ? DateTime.parse(g['targetDate'] as String)
                    : null,
                milestones: List<String>.from(g['milestones'] ?? []),
                relatedTheme: g['relatedTheme'] as String?,
              ))
          .toList(),
      context: PersonalContext(
        occupation: map['context']['occupation'] as String?,
        relationshipStatus: map['context']['relationshipStatus'] as String?,
        livingSituation: map['context']['livingSituation'] as String?,
        supportSystem: List<String>.from(map['context']['supportSystem'] ?? []),
        hasPriorTherapy: map['context']['hasPriorTherapy'] as bool? ?? false,
        therapyTypes: List<String>.from(map['context']['therapyTypes'] ?? []),
        sleepQuality: map['context']['sleepQuality'] as String? ?? 'fair',
        workLifeBalance: map['context']['workLifeBalance'] as String? ?? 'fair',
        hobbies: List<String>.from(map['context']['hobbies'] ?? []),
        communicationStylePreference:
            map['context']['communicationStylePreference'] as String? ?? 'balanced',
      ),
      lastUpdated: DateTime.parse(map['lastUpdated'] as String),
    );
  }

  // Crisis Logs (restricted access)

  Future<void> logCrisisEvent(CrisisEventLog event) async {
    final logs = await getCrisisLogs();
    logs.add(event);
    final json = jsonEncode(logs.map((e) => {
      'id': e.id,
      'odUserId': e.odUserId,
      'timestamp': e.timestamp.toIso8601String(),
      'category': e.category.name,
      'riskScore': e.riskScore,
      'contentSummary': e.contentSummary,
      'escalationLevel': e.escalationLevel.name,
      'resourceProvided': e.resourceProvided != null
          ? {
              'name': e.resourceProvided!.name,
              'phoneNumber': e.resourceProvided!.phoneNumber,
              'country': e.resourceProvided!.country,
            }
          : null,
      'trustedAdultNotified': e.trustedAdultNotified,
      'resolvedAt': e.resolvedAt?.toIso8601String(),
    }).toList());
    await _secureStorage.write(key: _keyCrisisLogs, value: json);
  }

  Future<List<CrisisEventLog>> getCrisisLogs() async {
    final json = await _secureStorage.read(key: _keyCrisisLogs);
    if (json == null) return [];

    final list = jsonDecode(json) as List;
    return list.map((e) {
      return CrisisEventLog(
        id: e['id'] as String,
        odUserId: e['odUserId'] as String,
        timestamp: DateTime.parse(e['timestamp'] as String),
        category: CrisisCategory.values.firstWhere(
          (c) => c.name == e['category'],
          orElse: () => CrisisCategory.selfHarm,
        ),
        riskScore: (e['riskScore'] as num).toDouble(),
        contentSummary: e['contentSummary'] as String,
        escalationLevel: CrisisEscalationLevel.values.firstWhere(
          (l) => l.name == e['escalationLevel'],
          orElse: () => CrisisEscalationLevel.low,
        ),
        resourceProvided: e['resourceProvided'] != null
            ? CrisisResource(
                name: e['resourceProvided']['name'] as String,
                phoneNumber: e['resourceProvided']['phoneNumber'] as String,
                country: e['resourceProvided']['country'] as String,
              )
            : null,
        trustedAdultNotified: e['trustedAdultNotified'] as bool? ?? false,
        resolvedAt: e['resolvedAt'] != null
            ? DateTime.parse(e['resolvedAt'] as String)
            : null,
      );
    }).toList();
  }

  // App State

  Future<void> setDisclaimerAcknowledged(bool acknowledged) async {
    await _prefs.setBool(_keyDisclaimerAcknowledged, acknowledged);
  }

  Future<bool> isDisclaimerAcknowledged() async {
    return _prefs.getBool(_keyDisclaimerAcknowledged) ?? false;
  }

  Future<void> setOnboardingComplete(bool complete) async {
    await _prefs.setBool(_keyOnboardingComplete, complete);
  }

  Future<bool> isOnboardingComplete() async {
    return _prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  // Data Export (GDPR)

  Future<Map<String, dynamic>> exportAllUserData() async {
    final user = await getUserProfile();
    final memory = await getUserMemory();
    final consent = await getConsentRecord();
    final crisisLogs = await getCrisisLogs();

    return {
      'exportedAt': DateTime.now().toIso8601String(),
      'user': user != null
          ? {
              'id': user.id,
              'name': user.name,
              'accountType': user.accountType.name,
              'createdAt': user.createdAt.toIso8601String(),
            }
          : null,
      'memory': memory != null
          ? {
              'recurringThemes': memory.recurringThemes.map((t) => t.theme).toList(),
              'goals': memory.goals.map((g) => g.title).toList(),
            }
          : null,
      'consentRecords': consent?.consents
          .map((c) => {'type': c.type.name, 'granted': c.isGranted})
          .toList(),
      'crisisInteractions': crisisLogs.length,
    };
  }

  // Full Delete (GDPR Right to Erasure)

  Future<void> deleteAllUserData() async {
    await _secureStorage.deleteAll();
    await _prefs.clear();
  }
}
