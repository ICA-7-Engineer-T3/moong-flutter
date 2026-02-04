class ChatMessage {
  final int? id;
  final String userId;
  final String moongId;
  final String message;
  final bool isUser;
  final DateTime createdAt;

  ChatMessage({
    this.id,
    required this.userId,
    required this.moongId,
    required this.message,
    required this.isUser,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  ChatMessage copyWith({
    int? id,
    String? userId,
    String? moongId,
    String? message,
    bool? isUser,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      moongId: moongId ?? this.moongId,
      message: message ?? this.message,
      isUser: isUser ?? this.isUser,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // For JSON serialization (SharedPreferences, API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'moongId': moongId,
      'message': message,
      'isUser': isUser,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as int?,
      userId: json['userId'] as String,
      moongId: json['moongId'] as String,
      message: json['message'] as String,
      isUser: json['isUser'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // For SQLite database
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'moong_id': moongId,
      'message': message,
      'is_user': isUser ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as int?,
      userId: map['user_id'] as String,
      moongId: map['moong_id'] as String,
      message: map['message'] as String,
      isUser: (map['is_user'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  @override
  String toString() {
    return 'ChatMessage{id: $id, userId: $userId, moongId: $moongId, message: $message, isUser: $isUser, createdAt: $createdAt}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatMessage &&
        other.id == id &&
        other.userId == userId &&
        other.moongId == moongId &&
        other.message == message &&
        other.isUser == isUser;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        moongId.hashCode ^
        message.hashCode ^
        isUser.hashCode;
  }
}
