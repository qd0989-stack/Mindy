enum AccountType { adult, teen }

enum CommunicationStyle { direct, gentle, balanced }

class UserModel {
  final String id;
  final AccountType accountType;
  final int age;
  final String? name;
  final CommunicationStyle communicationStyle;
  final List<String> currentStressors;
  final List<String> supportSystem;
  final bool hasPriorTherapy;
  final String? trustedAdultName;
  final String? trustedAdultContact;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool disclaimerAccepted;
  final Map<String, dynamic> sessionMemory;

  UserModel({
    required this.id,
    required this.accountType,
    required this.age,
    this.name,
    this.communicationStyle = CommunicationStyle.balanced,
    this.currentStressors = const [],
    this.supportSystem = const [],
    this.hasPriorTherapy = false,
    this.trustedAdultName,
    this.trustedAdultContact,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.disclaimerAccepted = false,
    this.sessionMemory = const {},
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool get isMinor => age < 18;

  bool get needsParentConsent => isMinor;

  UserModel copyWith({
    String? id,
    AccountType? accountType,
    int? age,
    String? name,
    CommunicationStyle? communicationStyle,
    List<String>? currentStressors,
    List<String>? supportSystem,
    bool? hasPriorTherapy,
    String? trustedAdultName,
    String? trustedAdultContact,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? disclaimerAccepted,
    Map<String, dynamic>? sessionMemory,
  }) {
    return UserModel(
      id: id ?? this.id,
      accountType: accountType ?? this.accountType,
      age: age ?? this.age,
      name: name ?? this.name,
      communicationStyle: communicationStyle ?? this.communicationStyle,
      currentStressors: currentStressors ?? this.currentStressors,
      supportSystem: supportSystem ?? this.supportSystem,
      hasPriorTherapy: hasPriorTherapy ?? this.hasPriorTherapy,
      trustedAdultName: trustedAdultName ?? this.trustedAdultName,
      trustedAdultContact: trustedAdultContact ?? this.trustedAdultContact,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      disclaimerAccepted: disclaimerAccepted ?? this.disclaimerAccepted,
      sessionMemory: sessionMemory ?? this.sessionMemory,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountType': accountType.name,
      'age': age,
      'name': name,
      'communicationStyle': communicationStyle.name,
      'currentStressors': currentStressors,
      'supportSystem': supportSystem,
      'hasPriorTherapy': hasPriorTherapy,
      'trustedAdultName': trustedAdultName,
      'trustedAdultContact': trustedAdultContact,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'disclaimerAccepted': disclaimerAccepted,
      'sessionMemory': sessionMemory,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      accountType: AccountType.values.firstWhere(
        (e) => e.name == json['accountType'],
        orElse: () => AccountType.adult,
      ),
      age: json['age'],
      name: json['name'],
      communicationStyle: CommunicationStyle.values.firstWhere(
        (e) => e.name == json['communicationStyle'],
        orElse: () => CommunicationStyle.balanced,
      ),
      currentStressors: List<String>.from(json['currentStressors'] ?? []),
      supportSystem: List<String>.from(json['supportSystem'] ?? []),
      hasPriorTherapy: json['hasPriorTherapy'] ?? false,
      trustedAdultName: json['trustedAdultName'],
      trustedAdultContact: json['trustedAdultContact'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      disclaimerAccepted: json['disclaimerAccepted'] ?? false,
      sessionMemory: Map<String, dynamic>.from(json['sessionMemory'] ?? {}),
    );
  }
}
