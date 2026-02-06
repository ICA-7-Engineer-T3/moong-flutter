import 'package:cloud_firestore/cloud_firestore.dart';

enum ShopCategory {
  clothes, // 의류
  accessories, // 잡화
  furniture, // 가구
  background, // 배경
  season, // 시즌
}

enum Currency {
  sprout, // 새싹
  credit, // 크레딧
}

class ShopItem {
  final String id;
  final ShopCategory category;
  final String name;
  final int price;
  final Currency currency;
  final String? imageUrl;
  final int? unlockDays; // null이면 바로 구매 가능, 숫자면 D-XX 표시

  ShopItem({
    required this.id,
    required this.category,
    required this.name,
    required this.price,
    required this.currency,
    this.imageUrl,
    this.unlockDays,
  });

  bool get isLocked => unlockDays != null && unlockDays! > 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category.name,
      'name': name,
      'price': price,
      'currency': currency.name,
      'imageUrl': imageUrl,
      'unlockDays': unlockDays,
    };
  }

  // For SQLite database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category.name,
      'name': name,
      'price': price,
      'currency': currency.name,
      'image_url': imageUrl,
      'unlock_days': unlockDays,
    };
  }

  factory ShopItem.fromJson(Map<String, dynamic> json) {
    return ShopItem(
      id: json['id'] as String,
      category: ShopCategory.values.firstWhere(
        (e) => e.name == json['category'],
      ),
      name: json['name'] as String,
      price: json['price'] as int,
      currency: Currency.values.firstWhere(
        (e) => e.name == json['currency'],
      ),
      imageUrl: json['imageUrl'] as String?,
      unlockDays: json['unlockDays'] as int?,
    );
  }

  // For SQLite database
  factory ShopItem.fromMap(Map<String, dynamic> map) {
    return ShopItem(
      id: map['id'] as String,
      category: ShopCategory.values.firstWhere(
        (e) => e.name == map['category'],
      ),
      name: map['name'] as String,
      price: map['price'] as int,
      currency: Currency.values.firstWhere(
        (e) => e.name == map['currency'],
      ),
      imageUrl: map['image_url'] as String?,
      unlockDays: map['unlock_days'] as int?,
    );
  }

  String getCategoryName() {
    switch (category) {
      case ShopCategory.clothes:
        return '의류';
      case ShopCategory.accessories:
        return '잡화';
      case ShopCategory.furniture:
        return '가구';
      case ShopCategory.background:
        return '배경';
      case ShopCategory.season:
        return '시즌';
    }
  }

  // For Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'category': category.name,
      'name': name,
      'price': price,
      'currency': currency.name,
      'imageUrl': imageUrl,
      'unlockDays': unlockDays,
    };
  }

  factory ShopItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) throw Exception('ShopItem document is null');

    return ShopItem(
      id: doc.id,
      category: ShopCategory.values.firstWhere((e) => e.name == data['category']),
      name: data['name'] as String,
      price: data['price'] as int,
      currency: Currency.values.firstWhere((e) => e.name == data['currency']),
      imageUrl: data['imageUrl'] as String?,
      unlockDays: data['unlockDays'] as int?,
    );
  }
}
