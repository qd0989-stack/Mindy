import 'package:equatable/equatable.dart';

/// Crisis detection result
class CrisisDetectionResult extends Equatable {
  final bool hasRisk;
  final CrisisCategory? category;
  final double riskScore; // 0.0 - 1.0
  final List<CrisisIndicator> indicators;
  final String recommendedResponse;
  final DateTime detectedAt;

  const CrisisDetectionResult({
    required this.hasRisk,
    this.category,
    this.riskScore = 0.0,
    this.indicators = const [],
    required this.recommendedResponse,
    required this.detectedAt,
  });

  /// Determine escalation level based on risk score
  CrisisEscalationLevel get escalationLevel {
    if (riskScore >= 0.9) return CrisisEscalationLevel.immediate;
    if (riskScore >= 0.7) return CrisisEscalationLevel.high;
    if (riskScore >= 0.4) return CrisisEscalationLevel.moderate;
    return CrisisEscalationLevel.low;
  }

  @override
  List<Object?> get props => [
        hasRisk,
        category,
        riskScore,
        indicators,
        recommendedResponse,
        detectedAt,
      ];
}

/// Crisis categories
enum CrisisCategory {
  selfHarm,
  suicide,
  abuse,
  harmToOthers,
  medicalEmergency,
  severeDepression,
  panicAttack,
  dissociation,
  psychosis,
}

/// Crisis indicators found in content
class CrisisIndicator extends Equatable {
  final String matchedText;
  final CrisisCategory category;
  final int position;
  final double weight;

  const CrisisIndicator({
    required this.matchedText,
    required this.category,
    required this.position,
    this.weight = 1.0,
  });

  @override
  List<Object?> get props => [matchedText, category, position, weight];
}

/// Crisis escalation levels
enum CrisisEscalationLevel {
  low, // Informational resources
  moderate, // Offer resources, gentle check-in
  high, // Urge to seek help, provide hotlines
  immediate, // Emergency services, trusted adult, crisis line
}

/// Crisis resource for a specific location
class CrisisResource extends Equatable {
  final String name;
  final String phoneNumber;
  final String? url;
  final String country;
  final String? region;
  final bool isAvailable24x7;
  final List<String> languages;

  const CrisisResource({
    required this.name,
    required this.phoneNumber,
    this.url,
    required this.country,
    this.region,
    this.isAvailable24x7 = true,
    this.languages = const ['en'],
  });

  @override
  List<Object?> get props => [
        name,
        phoneNumber,
        url,
        country,
        region,
        isAvailable24x7,
        languages,
      ];
}

/// Crisis event log entry (for audit purposes)
class CrisisEventLog extends Equatable {
  final String id;
  final String odUserId;
  final DateTime timestamp;
  final CrisisCategory category;
  final double riskScore;
  final String contentSummary; // Not the full content
  final CrisisEscalationLevel escalationLevel;
  final CrisisResource? resourceProvided;
  final bool trustedAdultNotified;
  final DateTime? resolvedAt;

  const CrisisEventLog({
    required this.id,
    required this.odUserId,
    required this.timestamp,
    required this.category,
    required this.riskScore,
    required this.contentSummary,
    required this.escalationLevel,
    this.resourceProvided,
    this.trustedAdultNotified = false,
    this.resolvedAt,
  });

  bool get isResolved => resolvedAt != null;

  @override
  List<Object?> get props => [
        id,
        odUserId,
        timestamp,
        category,
        riskScore,
        contentSummary,
        escalationLevel,
        resourceProvided,
        trustedAdultNotified,
        resolvedAt,
      ];
}
