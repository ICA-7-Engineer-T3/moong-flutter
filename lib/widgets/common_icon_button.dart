import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// Reusable circular icon button widget.
/// Extracted from _buildIconButton pattern duplicated 93x across 31 screens.
///
/// Original pattern from main_moong_screen.dart:296-316.
class CommonIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;
  final Color iconColor;
  final Color backgroundColor;
  final double backgroundOpacity;
  final List<BoxShadow>? boxShadow;

  const CommonIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = AppDimensions.iconButtonSize,
    this.iconSize = AppDimensions.iconButtonIconSize,
    this.iconColor = AppColors.greenDarker,
    this.backgroundColor = Colors.white,
    this.backgroundOpacity = 0.9,
    this.boxShadow,
  });

  /// Small variant (60x60, icon 30) commonly used in credit screens.
  const CommonIconButton.small({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor = AppColors.orangeDark,
    this.backgroundColor = Colors.white,
    this.backgroundOpacity = 0.9,
    this.boxShadow,
  })  : size = AppDimensions.iconButtonSizeSmall,
        iconSize = AppDimensions.iconButtonIconSizeSmall;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor.withValues(alpha: backgroundOpacity),
          shape: BoxShape.circle,
          boxShadow: boxShadow ??
              [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: AppDimensions.shadowBlurMedium,
                  spreadRadius: AppDimensions.shadowSpreadDefault,
                ),
              ],
        ),
        child: Icon(icon, size: iconSize, color: iconColor),
      ),
    );
  }
}
