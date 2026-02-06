import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';

/// Reusable currency display widget for credits and sprouts.
/// Extracted from _buildCreditContainer in shop_screen.dart:193-219
/// and credit_balance_screen.dart.
class CurrencyDisplay extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  final double fontSize;
  final double iconSize;

  const CurrencyDisplay({
    super.key,
    required this.icon,
    required this.value,
    required this.color,
    this.fontSize = AppDimensions.fontSizeLG,
    this.iconSize = 28.0,
  });

  /// Sprout display (green eco icon).
  const CurrencyDisplay.sprouts({
    super.key,
    required this.value,
    this.fontSize = AppDimensions.fontSizeLG,
    this.iconSize = 28.0,
  })  : icon = Icons.eco,
        color = Colors.green;

  /// Credit display (amber coin icon).
  const CurrencyDisplay.credits({
    super.key,
    required this.value,
    this.fontSize = AppDimensions.fontSizeLG,
    this.iconSize = 28.0,
  })  : icon = Icons.monetization_on,
        color = Colors.amber;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: iconSize),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF01020B),
            ),
          ),
        ],
      ),
    );
  }
}
