import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/// Top navigation bar with settings, home icons, and optional user level display.
///
/// This widget provides a consistent top bar across screens with:
/// - Settings icon (navigates to /settings)
/// - Home icon (navigates to /)
/// - Optional user level display
/// - Optional custom right widget
/// - Configurable icon color
class TopBar extends StatelessWidget {
  /// Whether to show the user's level on the right side.
  final bool showLevel;

  /// Custom widget to display on the right side (overrides level display).
  final Widget? rightWidget;

  /// Color for the icons (defaults to dark green).
  final Color iconColor;

  /// Padding around the top bar.
  final EdgeInsets padding;

  /// Text style for the level display.
  final TextStyle? levelTextStyle;

  const TopBar({
    super.key,
    this.showLevel = true,
    this.rightWidget,
    this.iconColor = const Color(0xFF2E7D32),
    this.padding = const EdgeInsets.all(18),
    this.levelTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildIconButton(
                context,
                Icons.settings_outlined,
                () => Navigator.pushNamed(context, '/settings'),
              ),
              const SizedBox(width: 18),
              _buildIconButton(
                context,
                Icons.home_outlined,
                () => Navigator.pushReplacementNamed(context, '/'),
              ),
            ],
          ),
          if (rightWidget != null)
            rightWidget!
          else if (showLevel)
            Text(
              '${authProvider.currentUser?.level ?? 1}',
              style: levelTextStyle ??
                  TextStyle(
                    fontFamily: 'Inder',
                    fontSize: 45,
                    color: iconColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildIconButton(
    BuildContext context,
    IconData icon,
    VoidCallback onTap,
  ) {
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
        child: Icon(icon, size: 40, color: iconColor),
      ),
    );
  }
}
