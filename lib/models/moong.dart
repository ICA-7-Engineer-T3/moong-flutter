enum MoongType {
  pet, // 펫 뭉 - 공감 100%
  mate, // 메이트 뭉 - 공감 80% 이성 20%
  guide, // 가이드 뭉 - 공감 50% 이성 50%
}

class Moong {
  final String id;
  final String userId;
  final String name;
  final MoongType type;
  final int level;
  final int intimacy; // 친밀도
  final DateTime createdAt;
  final DateTime? graduatedAt;
  final bool isActive;

  Moong({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.level = 1,
    this.intimacy = 0,
    required this.createdAt,
    this.graduatedAt,
    this.isActive = true,
  });

  Moong copyWith({
    String? id,
    String? userId,
    String? name,
    MoongType? type,
    int? level,
    int? intimacy,
    DateTime? createdAt,
    DateTime? graduatedAt,
    bool? isActive,
  }) {
    return Moong(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      level: level ?? this.level,
      intimacy: intimacy ?? this.intimacy,
      createdAt: createdAt ?? this.createdAt,
      graduatedAt: graduatedAt ?? this.graduatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'type': type.toString().split('.').last,
      'level': level,
      'intimacy': intimacy,
      'createdAt': createdAt.toIso8601String(),
      'graduatedAt': graduatedAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  // For SQLite database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type.toString().split('.').last,
      'level': level,
      'intimacy': intimacy,
      'created_at': createdAt.millisecondsSinceEpoch,
      'graduated_at': graduatedAt?.millisecondsSinceEpoch,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory Moong.fromJson(Map<String, dynamic> json) {
    return Moong(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      type: MoongType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      level: json['level'] as int? ?? 1,
      intimacy: json['intimacy'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      graduatedAt: json['graduatedAt'] != null
          ? DateTime.parse(json['graduatedAt'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  // For SQLite database
  factory Moong.fromMap(Map<String, dynamic> map) {
    return Moong(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      type: MoongType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
      ),
      level: map['level'] as int? ?? 1,
      intimacy: map['intimacy'] as int? ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      graduatedAt: map['graduated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['graduated_at'] as int)
          : null,
      isActive: (map['is_active'] as int) == 1,
    );
  }

  String getTypeDescription() {
    switch (type) {
      case MoongType.pet:
        return '펫 뭉\n공감 100%';
      case MoongType.mate:
        return '메이트 뭉\n공감 80% 이성 20%';
      case MoongType.guide:
        return '가이드 뭉\n공감 50% 이성 50%';
    }
  }

  String getTypeComment() {
    switch (type) {
      case MoongType.pet:
        return '"00 말에 100% 공감해!';
      case MoongType.mate:
        return '"00감정 충분히 이해해"';
      case MoongType.guide:
        return '"00한 감정을 느꼈구나! 00방향으로 해볼까?"';
    }
  }
}
