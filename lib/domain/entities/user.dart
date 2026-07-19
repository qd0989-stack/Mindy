import 'package:equatable/equatable.dart';

/// Account type for age-appropriate experience
enum AccountType { adult, teen }

/// User subscription status
enum SubscriptionStatus { free, premium }

/// User entity representing the app user
class User extends Equatable {
  final String id;
  final String? name;
  final DateTime? dateOfBirth;
  final AccountType accountType;
  final SubscriptionStatus subscriptionStatus;
  final String? trustedAdultContact; // For teen accounts, crisis escalation
  final CommunicationStyle communicationStyle;
  final DateTime createdAt;
  final DateTime? lastActiveAt;

  const User({
    required this.id,
    this.name,
    this.dateOfBirth,
    required this.accountType,
    required this.subscriptionStatus,
    this.trustedAdultContact,
    this.communicationStyle = CommunicationStyle.gentle,
    required this.createdAt,
    this.lastActiveAt,
  });

  /// Calculate if user is under legal adulthood age (18)
  bool get isMinor {
    if (dateOfBirth == null) return false;
    final age = DateTime.now().difference(dateOfBirth!).inDays ~/ 365;
    return age < 18;
  }

  /// Get effective crisis protocol strictness
  CrisisProtocolLevel get crisisProtocolLevel {
    if (isMinor) return CrisisProtocolLevel.strict;
    if (accountType == AccountType.teen) return CrisisProtocolLevel.enhanced;
    return CrisisProtocolLevel.standard;
  }

  User copyWith({
    String? id,
    String? name,
    DateTime? dateOfBirth,
    AccountType? accountType,
    SubscriptionStatus? subscriptionStatus,
    String? trustedAdultContact,
    CommunicationStyle? communicationStyle,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      accountType: accountType ?? this.accountType,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      trustedAdultContact: trustedAdultContact ?? this.trustedAdultContact,
      communicationStyle: communicationStyle ?? this.communicationStyle,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        dateOfBirth,
        accountType,
        subscriptionStatus,
        trustedAdultContact,
        communicationStyle,
        createdAt,
        lastActiveAt,
      ];
}

/// Communication style preference
enum CommunicationStyle {
  gentle, // Softer, more supportive tone
  direct, // More straightforward, practical
  balanced, // Mix of both approaches
}

/// Crisis protocol strictness levels
enum CrisisProtocolLevel {
  standard, // Standard response
  enhanced, // Enhanced monitoring for teen accounts
  strict, // Strictest protocol for minors
}
