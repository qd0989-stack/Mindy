import '../domain/entities/crisis_detection.dart';
import '../core/constants/app_constants.dart';

/// Real-time crisis detection service
/// Scans text and speech for risk indicators
class CrisisDetectionService {
  // Risk keywords and phrases for each crisis category
  static final Map<CrisisCategory, List<CrisisPattern>> _patterns = {
    CrisisCategory.selfHarm: [
      CrisisPattern(
        pattern: RegExp(r'\b(cut|burn|self-harm|selfharm|hurting myself)\b',
            caseSensitive: false),
        weight: 0.9,
      ),
      CrisisPattern(
        pattern: RegExp(
            r'\b(scar|scarred|bleeding|injuring|harm myself)\b',
            caseSensitive: false),
        weight: 0.7,
      ),
    ],
    CrisisCategory.suicide: [
      CrisisPattern(
        pattern: RegExp(
            r'\b(suicide|suicidal|kill myself|end my life|want to die|'
            r'dying|not worth|life not worth|no point to|'
            r'better off dead)\b',
            caseSensitive: false),
        weight: 1.0,
      ),
      CrisisPattern(
        pattern: RegExp(
            r'\b(how to|ways to|method of)\s*(die|kill|end)',
            caseSensitive: false),
        weight: 1.0,
      ),
      CrisisPattern(
        pattern: RegExp(r'\b(rope|pills|knife|pills|bridge|jump)\s*(plan|to)\b',
            caseSensitive: false),
        weight: 0.95,
      ),
    ],
    CrisisCategory.abuse: [
      CrisisPattern(
        pattern: RegExp(
            r'\b(abus|beat|hurt|hit|threaten|control|fear)\s*(me|my)\b',
            caseSensitive: false),
        weight: 0.8,
      ),
      CrisisPattern(
        pattern:
            RegExp(r'\b(unsafe|dangerous|abused|hitting me|hurting me)\b',
                caseSensitive: false),
        weight: 0.8,
      ),
    ],
    CrisisCategory.harmToOthers: [
      CrisisPattern(
        pattern: RegExp(
            r'\b(hurt|kill|harm)\s*(them|him|her|people|someone)\b',
            caseSensitive: false),
        weight: 0.9,
      ),
      CrisisPattern(
        pattern:
            RegExp(r'\b(revenge|get back|make them pay)\b', caseSensitive: false),
        weight: 0.6,
      ),
    ],
    CrisisCategory.severeDepression: [
      CrisisPattern(
        pattern: RegExp(
            r'\b(can.t get out of bed|nothing matters|empty|hopeless|'
            r'worthless|burden|give up on everything)\b',
            caseSensitive: false),
        weight: 0.8,
      ),
    ],
    CrisisCategory.panicAttack: [
      CrisisPattern(
        pattern: RegExp(
            r'\b(panic|can.t breathe|heart racing|chest pain|'
            r'shaking|terrified|going to die|losing control)\b',
            caseSensitive: false),
        weight: 0.7,
      ),
    ],
    CrisisCategory.dissociation: [
      CrisisPattern(
        pattern: RegExp(
            r'\b(disconnected|not real|derealization|depersonalization|'
            r'out of body|floating|numb)\b',
            caseSensitive: false),
        weight: 0.6,
      ),
    ],
    CrisisCategory.psychosis: [
      CrisisPattern(
        pattern: RegExp(
            r'\b(hearing voices|seeing things|hallucinating|delusions|'
            r'paranoid|someone watching|believes|schizophrenia)\b',
            caseSensitive: false),
        weight: 0.85,
      ),
    ],
    CrisisCategory.medicalEmergency: [
      CrisisPattern(
        pattern: RegExp(
            r'\b(overdose|poison|allergic reaction|unconscious|'
            r'seizure|choking|severe bleeding|can.t breathe)\b',
            caseSensitive: false),
        weight: 0.95,
      ),
    ],
  };

  /// Detect crisis risk in text content
  CrisisDetectionResult detectRisk(String content) {
    if (content.isEmpty) {
      return CrisisDetectionResult(
        hasRisk: false,
        recommendedResponse: 'Continue normal interaction',
        detectedAt: DateTime.now(),
      );
    }

    final indicators = <CrisisIndicator>[];
    double totalRiskScore = 0.0;
    CrisisCategory? primaryCategory;

    // Check each category
    for (final entry in _patterns.entries) {
      final category = entry.key;
      final patterns = entry.value;

      for (final pattern in patterns) {
        final matches = pattern.pattern.allMatches(content);
        for (final match in matches) {
          indicators.add(CrisisIndicator(
            matchedText: match.group(0) ?? '',
            category: category,
            position: match.start,
            weight: pattern.weight,
          ));
          totalRiskScore += pattern.weight;
        }
      }
    }

    // Normalize risk score to 0-1 range
    final normalizedScore = (totalRiskScore / indicators.length)
        .clamp(0.0, 1.0)
        .clamp(0.0, 1.0);

    // Determine primary category (highest weighted indicators)
    if (indicators.isNotEmpty) {
      final categoryScores = <CrisisCategory, double>{};
      for (final indicator in indicators) {
        categoryScores[indicator.category] =
            (categoryScores[indicator.category] ?? 0) + indicator.weight;
      }
      primaryCategory = categoryScores.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
    }

    // Determine response based on risk score
    final response = _generateResponse(
      normalizedScore,
      primaryCategory,
      indicators.length,
    );

    return CrisisDetectionResult(
      hasRisk: normalizedScore >= AppConstants.crisisRiskThreshold ||
          indicators.length >= AppConstants.crisisKeywordMatchCount,
      category: primaryCategory,
      riskScore: normalizedScore,
      indicators: indicators,
      recommendedResponse: response,
      detectedAt: DateTime.now(),
    );
  }

  String _generateResponse(
    double riskScore,
    CrisisCategory? category,
    int indicatorCount,
  ) {
    if (riskScore >= 0.9) {
      return 'EMERGENCY: Immediate crisis response required. '
          'Provide emergency services contact (112 in EU). '
          'Do not leave user alone if possible.';
    } else if (riskScore >= 0.7) {
      return 'HIGH RISK: Provide crisis hotlines and encourage '
          'immediate professional help. '
          'For minors, consider trusted adult notification.';
    } else if (riskScore >= 0.4) {
      return 'MODERATE RISK: Offer supportive resources and '
          'check in with user wellbeing. '
          'Be prepared to escalate if risk increases.';
    }
    return 'LOW RISK: Continue supportive conversation. '
        'Offer resources if appropriate.';
  }

  /// Get localized crisis resources
  List<CrisisResource> getCrisisResources({String country = 'EU'}) {
    // Return region-specific resources
    return _euCrisisResources;
  }

  static final List<CrisisResource> _euCrisisResources = [
    const CrisisResource(
      name: 'Samaritans',
      phoneNumber: '116 123',
      url: 'https://www.samaritans.org',
      country: 'UK',
      isAvailable24x7: true,
      languages: ['en'],
    ),
    const CrisisResource(
      name: 'Crisis Text Line',
      phoneNumber: '686868',
      url: 'https://www.crisistextline.org',
      country: 'US',
      isAvailable24x7: true,
      languages: ['en', 'es'],
    ),
    const CrisisResource(
      name: 'Telefonseelsorge',
      phoneNumber: '0800 111 0 111',
      url: 'https://www.telefonseelsorge.de',
      country: 'DE',
      isAvailable24x7: true,
      languages: ['de'],
    ),
    const CrisisResource(
      name: 'SOS Amitié',
      phoneNumber: '09 72 39 40 50',
      url: 'https://www.sos-amitie.com',
      country: 'FR',
      isAvailable24x7: true,
      languages: ['fr'],
    ),
    const CrisisResource(
      name: 'Telefono Amico',
      phoneNumber: '199 284 284',
      url: 'https://www.telefonoamico.it',
      country: 'IT',
      isAvailable24x7: true,
      languages: ['it'],
    ),
  ];
}

/// Pattern for crisis detection
class CrisisPattern {
  final RegExp pattern;
  final double weight;

  const CrisisPattern({
    required this.pattern,
    this.weight = 1.0,
  });
}
