import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Reusable gradient background with SafeArea.
/// Extracted from the common pattern of Container + gradient + SafeArea
/// found in virtually every screen.
class GradientBackground extends StatelessWidget {
  final List<Color> colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final Widget child;

  const GradientBackground({
    super.key,
    required this.colors,
    required this.child,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
  });

  /// Green gradient (Main Moong, Garden).
  const GradientBackground.green({
    super.key,
    required this.child,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
  }) : colors = AppColors.greenGradient;

  /// Blue gradient (Quest, Chat).
  const GradientBackground.blue({
    super.key,
    required this.child,
  })  : colors = AppColors.blueGradient,
        begin = Alignment.topLeft,
        end = Alignment.bottomRight;

  /// Orange gradient (Credits).
  const GradientBackground.orange({
    super.key,
    required this.child,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
  }) : colors = AppColors.orangeGradient;

  /// Pink gradient (Sakura).
  const GradientBackground.pink({
    super.key,
    required this.child,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
  }) : colors = AppColors.pinkGradient;

  /// Purple gradient (Settings).
  const GradientBackground.purple({
    super.key,
    required this.child,
  })  : colors = AppColors.purpleGradient,
        begin = Alignment.topLeft,
        end = Alignment.bottomRight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: colors,
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}
