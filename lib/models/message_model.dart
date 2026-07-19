enum MessageType { text, voice, system }

class MessageModel {
  final String id;
  final String content;
  final MessageType type;
  final bool isFromUser;
  final DateTime timestamp;
  final bool containsCrisisKeywords;
  final Map<String, dynamic>? metadata;

  MessageModel({
    required this.id,
    required this.content,
    this.type = MessageType.text,
    required this.isFromUser,
    DateTime? timestamp,
    this.containsCrisisKeywords = false,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();

  MessageModel copyWith({
    String? id,
    String? content,
    MessageType? type,
    bool? isFromUser,
    DateTime? timestamp,
    bool? containsCrisisKeywords,
    Map<String, dynamic>? metadata,
  }) {
    return MessageModel(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      isFromUser: isFromUser ?? this.isFromUser,
      timestamp: timestamp ?? this.timestamp,
      containsCrisisKeywords:
          containsCrisisKeywords ?? this.containsCrisisKeywords,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.name,
      'isFromUser': isFromUser,
      'timestamp': timestamp.toIso8601String(),
      'containsCrisisKeywords': containsCrisisKeywords,
      'metadata': metadata,
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      content: json['content'],
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      isFromUser: json['isFromUser'],
      timestamp: DateTime.parse(json['timestamp']),
      containsCrisisKeywords: json['containsCrisisKeywords'] ?? false,
      metadata: json['metadata'],
    );
  }
}
