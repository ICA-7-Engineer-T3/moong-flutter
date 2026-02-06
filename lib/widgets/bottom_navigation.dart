import 'package:flutter/material.dart';

/// Navigation item configuration for bottom navigation.
class NavItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? gradientStart;
  final Color? gradientEnd;
  final Color? shadowColor;

  const NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.gradientStart,
    this.gradientEnd,
    this.shadowColor,
  });
}

/// Bottom navigation bar with customizable nav items.
///
/// This widget provides a consistent bottom navigation across screens with:
/// - Multiple navigation buttons with icons and labels
/// - Optional back button
/// - Optional garden button
/// - Customizable button colors
class BottomNavigation extends StatelessWidget {
  /// List of navigation items to display.
  final List<NavItem> items;

  /// Whether to show a back button on the left.
  final bool showBackButton;

  /// Whether to show a garden button on the right (when using simple layout).
  final bool showGardenButton;

  /// Layout mode: 'centered' for evenly spaced items, 'split' for back/garden on sides.
  final String layout;

  /// Padding around the bottom navigation.
  final EdgeInsets padding;

  /// Default gradient start color for buttons.
  final Color defaultGradientStart;

  /// Default gradient end color for buttons.
  final Color defaultGradientEnd;

  /// Default shadow color for buttons.
  final Color defaultShadowColor;

  const BottomNavigation({
    super.key,
    required this.items,
    this.showBackButton = false,
    this.showGardenButton = false,
    this.layout = 'centered',
    this.padding = const EdgeInsets.only(bottom: 20),
    this.defaultGradientStart = const Color(0xFF66BB6A),
    this.defaultGradientEnd = const Color(0xFF43A047),
    this.defaultShadowColor = const Color(0xFF43A047),
  });

  @override
  Widget build(BuildContext context) {
    if (layout == 'split') {
      return _buildSplitLayout(context);
    } else if (layout == 'icons-only') {
      return _buildIconsOnlyLayout(context);
    }
    return _buildCenteredLayout(context);
  }

  /// Centered layout with evenly spaced navigation items.
  Widget _buildCenteredLayout(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items
            .map((item) => _buildNavButton(
                  item.icon,
                  item.label,
                  item.onTap,
                  item.gradientStart ?? defaultGradientStart,
                  item.gradientEnd ?? defaultGradientEnd,
                  item.shadowColor ?? defaultShadowColor,
                ))
            .toList(),
      ),
    );
  }

  /// Split layout with back button on left and garden button on right.
  Widget _buildSplitLayout(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showBackButton)
            Padding(
              padding: const EdgeInsets.only(left: 27),
              child: _buildIconButton(
                Icons.arrow_back,
                () => Navigator.pop(context),
              ),
            ),
          if (showGardenButton)
            Padding(
              padding: const EdgeInsets.only(right: 27),
              child: _buildIconButton(
                Icons.yard_outlined,
                () => Navigator.pushNamed(context, '/garden'),
              ),
            ),
        ],
      ),
    );
  }

  /// Icons-only layout with back button on left and action icons on right.
  Widget _buildIconsOnlyLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(27),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showBackButton)
            _buildIconButton(
              Icons.arrow_back,
              () => Navigator.pop(context),
            ),
          Row(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Row(
                children: [
                  if (index > 0) const SizedBox(width: 20),
                  _buildIconButton(item.icon, item.onTap),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Navigation button with icon, label, and gradient background.
  Widget _buildNavButton(
    IconData icon,
    String label,
    VoidCallback onTap,
    Color gradientStart,
    Color gradientEnd,
    Color shadowColor,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 83,
            height: 83,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [gradientStart, gradientEnd],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: shadowColor.withValues(alpha: 0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(icon, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Simple icon button (circular, white background).
  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 83,
        height: 83,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(icon, size: 40, color: const Color(0xFF2E7D32)),
      ),
    );
  }
}
