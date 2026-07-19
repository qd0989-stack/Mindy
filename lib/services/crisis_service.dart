class CrisisDetectionService {
  static final List<String> _crisisKeywords = [
    'suicide', 'kill myself', 'end my life', 'want to die',
    'self harm', 'self-harm', 'cut myself', 'hurt myself',
    'overdose', 'hang myself', 'dont want to live',
    'no reason to live', 'better off dead', 'abuse', 'abused',
    'abusing', 'touched inappropriately', 'molested', 'raped',
    'beaten', 'attack', 'danger', 'emergency', 'police',
    'help me', 'cant go on', 'giving up', 'helpless',
    'hopeless', 'worthless', 'end it all', 'kill me', 'murder',
  ];

  static final List<String> _immediateDangerKeywords = [
    'weapon', 'gun', 'knife', 'pills', 'medication',
    'bleeding', 'unconscious', 'not breathing', 'overdose', 'poison',
  ];

  static final List<String> _abuseKeywords = [
    'abuse', 'abused', 'abusing', 'hurt', 'touched',
    'inappropriate', 'molested', 'raped', 'beaten', 'hit',
    'violence', 'threatening', 'controlling', 'manipulating',
  ];

  CrisisResult analyze(String text) {
    final lowerText = text.toLowerCase();
    bool hasCrisis = _crisisKeywords.any((k) => lowerText.contains(k));
    bool hasImmediate = _immediateDangerKeywords.any((k) => lowerText.contains(k));
    bool hasAbuse = _abuseKeywords.any((k) => lowerText.contains(k));

    CrisisLevel level = CrisisLevel.none;
    if (hasImmediate) level = CrisisLevel.immediate;
    else if (hasCrisis && hasAbuse) level = CrisisLevel.high;
    else if (hasCrisis) level = CrisisLevel.moderate;
    else if (hasAbuse) level = CrisisLevel.elevated;

    return CrisisResult(
      level: level,
      text: text,
      detectedKeywords: _getDetectedKeywords(lowerText),
      requiresEscalation: level != CrisisLevel.none,
    );
  }

  List<String> _getDetectedKeywords(String text) {
    List<String> detected = [];
    for (var k in _crisisKeywords + _immediateDangerKeywords + _abuseKeywords) {
      if (text.contains(k)) detected.add(k);
    }
    return detected;
  }

  CrisisResponse getCrisisResponse(CrisisResult result) {
    switch (result.level) {
      case CrisisLevel.immediate:
        return CrisisResponse(
          message: "I hear that you are in urgent danger. Please contact emergency services immediately. Call 112 (EU) or your local emergency number.",
          resources: [CrisisResource(name: 'Emergency Services', phone: '112', description: 'EU Emergency')],
          requiresImmediateAction: true,
        );
      case CrisisLevel.high:
        return CrisisResponse(
          message: "Thank you for sharing this. What you are experiencing sounds really difficult. Please reach out to a crisis helpline.",
          resources: [CrisisResource(name: 'Find a Helpline', website: 'https://findahelpline.com', description: 'Find crisis support')],
          requiresImmediateAction: false,
        );
      case CrisisLevel.moderate:
        return CrisisResponse(
          message: "Thank you for telling me how you are feeling. It takes courage to share these thoughts. Support is available.",
          resources: [CrisisResource(name: 'Befrienders Worldwide', website: 'https://www.befrienders.org', description: 'Emotional support')],
          requiresImmediateAction: false,
        );
      case CrisisLevel.elevated:
        return CrisisResponse(
          message: "Thank you for trusting me with this. You deserve support, and there are people who can help.",
          resources: [],
          requiresImmediateAction: false,
        );
      case CrisisLevel.none:
        return CrisisResponse(message: '', resources: [], requiresImmediateAction: false);
    }
  }
}

enum CrisisLevel { none, elevated, moderate, high, immediate }

class CrisisResult {
  final CrisisLevel level;
  final String text;
  final List<String> detectedKeywords;
  final bool requiresEscalation;
  CrisisResult({required this.level, required this.text, required this.detectedKeywords, required this.requiresEscalation});
}

class CrisisResource {
  final String name;
  final String? phone;
  final String? website;
  final String description;
  const CrisisResource({required this.name, this.phone, this.website, required this.description});
}

class CrisisResponse {
  final String message;
  final List<CrisisResource> resources;
  final bool requiresImmediateAction;
  CrisisResponse({required this.message, required this.resources, required this.requiresImmediateAction});
}
