class User {
  final String id;
  final String nickname;
  final int level;
  final int credits;
  final int sprouts;
  final DateTime createdAt;

  User({
    required this.id,
    required this.nickname,
    this.level = 1,
    this.credits = 250,
    this.sprouts = 250,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  User copyWith({
    String? id,
    String? nickname,
    int? level,
    int? credits,
    int? sprouts,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      level: level ?? this.level,
      credits: credits ?? this.credits,
      sprouts: sprouts ?? this.sprouts,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'level': level,
      'credits': credits,
      'sprouts': sprouts,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // For SQLite database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nickname': nickname,
      'level': level,
      'credits': credits,
      'sprouts': sprouts,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      level: json['level'] as int? ?? 1,
      credits: json['credits'] as int? ?? 250,
      sprouts: json['sprouts'] as int? ?? 250,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  // For SQLite database
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      nickname: map['nickname'] as String,
      level: map['level'] as int? ?? 1,
      credits: map['credits'] as int? ?? 250,
      sprouts: map['sprouts'] as int? ?? 250,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }
}
