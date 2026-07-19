import 'package:equatable/equatable.dart';

/// User consent records for GDPR compliance
class ConsentRecord extends Equatable {
  final String id;
  final String odUserId;
  final List<ConsentItem> consents;
  final DateTime recordedAt;
  final String? guardianConsentId; // For minors, links to guardian's consent
  final DateTime? guardianConsentDate;

  const ConsentRecord({
    required this.id,
    required this.odUserId,
    required this.consents,
    required this.recordedAt,
    this.guardianConsentId,
    this.guardianConsentDate,
  });

  bool hasConsentedTo(ConsentType type) {
    final consent = consents.firstWhere(
      (c) => c.type == type,
      orElse: () => const ConsentItem(
        type: ConsentType.essential,
        isGranted: false,
        recordedAt: null,
      ),
    );
    return consent.isGranted;
  }

  ConsentRecord copyWith({
    String? id,
    String? odUserId,
    List<ConsentItem>? consents,
    DateTime? recordedAt,
    String? guardianConsentId,
    DateTime? guardianConsentDate,
  }) {
    return ConsentRecord(
      id: id ?? this.id,
      odUserId: odUserId ?? this.odUserId,
      consents: consents ?? this.consents,
      recordedAt: recordedAt ?? this.recordedAt,
      guardianConsentId: guardianConsentId ?? this.guardianConsentId,
      guardianConsentDate:
          guardianConsentDate ?? this.guardianConsentDate,
    );
  }

  @override
  List<Object?> get props => [
        id,
        odUserId,
        consents,
        recordedAt,
        guardianConsentId,
        guardianConsentDate,
      ];
}

/// Individual consent item
class ConsentItem extends Equatable {
  final ConsentType type;
  final bool isGranted;
  final DateTime? recordedAt;
  final String? version; // Consent form version

  const ConsentItem({
    required this.type,
    required this.isGranted,
    this.recordedAt,
    this.version,
  });

  @override
  List<Object?> get props => [type, isGranted, recordedAt, version];
}

/// Types of consent required
enum ConsentType {
  essential, // Required for app to function (data storage, security)
  analytics, // Usage analytics
  personalizedExperience, // AI personalization
  crashReporting, // Error reporting
  marketing, // Promotional communications
}

/// Consent form types
enum ConsentFormType {
  initialOnboarding,
  minorGuardian, // Special form for minor's guardian
  dataProcessingUpdate, // When privacy policy changes
  marketingOptIn,
}
