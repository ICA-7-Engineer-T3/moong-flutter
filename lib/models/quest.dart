enum QuestType {
  walk, // 걷기 퀘스트
}

class Quest {
  final String id;
  final String userId;
  final String? moongId;
  final QuestType type;
  final int target; // 목표 (3000, 7000, 10000)
  final int progress; // 현재 진행도
  final bool completed;
  final DateTime createdAt;
  final DateTime? completedAt;

  Quest({
    required this.id,
    required this.userId,
    this.moongId,
    required this.type,
    required this.target,
    this.progress = 0,
    this.completed = false,
    required this.createdAt,
    this.completedAt,
  });

  double get progressPercentage => (progress / target).clamp(0.0, 1.0);

  Quest copyWith({
    String? id,
    String? userId,
    String? moongId,
    QuestType? type,
    int? target,
    int? progress,
    bool? completed,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Quest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      moongId: moongId ?? this.moongId,
      type: type ?? this.type,
      target: target ?? this.target,
      progress: progress ?? this.progress,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'moongId': moongId,
      'type': type.name,
      'target': target,
      'progress': progress,
      'completed': completed,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  // For SQLite database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'moong_id': moongId,
      'type': type.name,
      'target': target,
      'progress': progress,
      'completed': completed ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'completed_at': completedAt?.millisecondsSinceEpoch,
    };
  }

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['id'] as String,
      userId: json['userId'] as String,
      moongId: json['moongId'] as String?,
      type: QuestType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      target: json['target'] as int,
      progress: json['progress'] as int? ?? 0,
      completed: json['completed'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  // For SQLite database
  factory Quest.fromMap(Map<String, dynamic> map) {
    return Quest(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      moongId: map['moong_id'] as String?,
      type: QuestType.values.firstWhere(
        (e) => e.name == map['type'],
      ),
      target: map['target'] as int,
      progress: map['progress'] as int? ?? 0,
      completed: (map['completed'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      completedAt: map['completed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completed_at'] as int)
          : null,
    );
  }

  String getQuestName() {
    switch (target) {
      case 3000:
        return '퀘스트 1';
      case 7000:
        return '퀘스트 2';
      case 10000:
        return '퀘스트 3';
      default:
        return '퀘스트';
    }
  }

  String getTargetText() {
    return '$target보';
  }
}
