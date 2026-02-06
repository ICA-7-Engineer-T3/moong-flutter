import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String? email; // For Firebase Auth
  final String nickname;
  final int level;
  final int credits;
  final int sprouts;
  final DateTime createdAt;

  User({
    required this.id,
    this.email,
    required this.nickname,
    this.level = 1,
    this.credits = 250,
    this.sprouts = 250,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  User copyWith({
    String? id,
    String? email,
    String? nickname,
    int? level,
    int? credits,
    int? sprouts,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
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
      'email': email,
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
      email: json['email'] as String?,
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
      email: map['email'] as String?,
      nickname: map['nickname'] as String,
      level: map['level'] as int? ?? 1,
      credits: map['credits'] as int? ?? 250,
      sprouts: map['sprouts'] as int? ?? 250,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  // For Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'nickname': nickname,
      'level': level,
      'credits': credits,
      'sprouts': sprouts,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory User.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) throw Exception('User document is null');

    return User(
      id: doc.id,
      email: data['email'] as String?,
      nickname: data['nickname'] as String,
      level: data['level'] as int? ?? 1,
      credits: data['credits'] as int? ?? 250,
      sprouts: data['sprouts'] as int? ?? 250,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
