import 'package:flutter/material.dart';

/// Configuration for background preview screens.
/// Extracted common pattern from 4 background screens (95%+ duplicate code).
class BackgroundConfig {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color accentColor;
  final List<Color> gradientColors;
  final int priceCredits;
  final Widget Function(BuildContext)? decorativeElementsBuilder;

  const BackgroundConfig({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.accentColor,
    required this.gradientColors,
    required this.priceCredits,
    this.decorativeElementsBuilder,
  });

  /// Forest background configuration
  static BackgroundConfig get forest => BackgroundConfig(
        title: '신비한 숲',
        description: '깊은 숲 속에서\n뭉이와 함께 평화로운 시간을\n보내세요',
        icon: Icons.forest,
        iconColor: const Color(0xFF2E7D32),
        accentColor: const Color(0xFF66BB6A),
        gradientColors: const [
          Color(0xFF1B5E20),
          Color(0xFF2E7D32),
          Color(0xFF43A047),
          Color(0xFF66BB6A),
        ],
        priceCredits: 150,
        decorativeElementsBuilder: null, // Can be added if needed
      );

  /// Beach background configuration
  static BackgroundConfig get beach => BackgroundConfig(
        title: '따뜻한 해변',
        description: '푸른 바다와 따뜻한 햇살\n뭉이와 함께 여름 휴가를\n즐겨보세요',
        icon: Icons.beach_access,
        iconColor: const Color(0xFF29B6F6),
        accentColor: const Color(0xFF29B6F6),
        gradientColors: const [
          Color(0xFF4FC3F7),
          Color(0xFF29B6F6),
          Color(0xFFFFF59D),
          Color(0xFFFFEE58),
        ],
        priceCredits: 200,
        decorativeElementsBuilder: null,
      );

  /// Space background configuration
  static BackgroundConfig get space => BackgroundConfig(
        title: '신비로운 우주',
        description: '무한한 우주 공간에서\n뭉이와 함께 별을 관찰하고\n꿈을 키워보세요',
        icon: Icons.rocket_launch,
        iconColor: const Color(0xFF1976D2),
        accentColor: const Color(0xFF1976D2),
        gradientColors: const [
          Color(0xFF0D47A1),
          Color(0xFF1565C0),
          Color(0xFF1976D2),
          Color(0xFF1E88E5),
        ],
        priceCredits: 300,
        decorativeElementsBuilder: null,
      );

  /// Sakura background configuration
  static BackgroundConfig get sakura => BackgroundConfig(
        title: '벚꽃 동산',
        description: '봄날 벚꽃이 흩날리는\n아름다운 동산에서\n뭉이와 함께 힐링하세요',
        icon: Icons.local_florist,
        iconColor: const Color(0xFFEC407A),
        accentColor: const Color(0xFFEC407A),
        gradientColors: const [
          Color(0xFFFCE4EC),
          Color(0xFFF8BBD0),
          Color(0xFFF48FB1),
        ],
        priceCredits: 180,
        decorativeElementsBuilder: null,
      );
}
