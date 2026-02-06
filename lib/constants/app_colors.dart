import 'package:flutter/material.dart';

/// Centralized color constants for the Moong app.
/// Extracted from 469 hardcoded Color(0xFF...) values across 40+ screen files.
class AppColors {
  AppColors._();

  // --- Green Theme (Main Moong, Garden) ---
  static const Color greenLightest = Color(0xFFE8F5E9);
  static const Color greenLight = Color(0xFFC8E6C9);
  static const Color greenMediumLight = Color(0xFFA5D6A7);
  static const Color greenMedium = Color(0xFF66BB6A);
  static const Color greenDark = Color(0xFF43A047);
  static const Color greenDarker = Color(0xFF2E7D32);
  static const Color greenDarkest = Color(0xFF16623B);
  static const Color greenAccent = Color(0xFF1B5E20);

  // --- Blue Theme (Quest, Chat) ---
  static const Color blueLightest = Color(0xFFE3F2FD);
  static const Color blueLight = Color(0xFFBBDEFB);
  static const Color blueMediumLight = Color(0xFF90CAF9);
  static const Color blueMedium = Color(0xFF42A5F5);
  static const Color blueDark = Color(0xFF1976D2);
  static const Color blueDarker = Color(0xFF0288D1);
  static const Color blueDarkest = Color(0xFF0277BD);
  static const Color blueNavy = Color(0xFF0D47A1);
  static const Color blueNavyMedium = Color(0xFF1565C0);
  static const Color blueNavyLight = Color(0xFF1E88E5);
  static const Color blueSky = Color(0xFF4FC3F7);
  static const Color blueSkyDark = Color(0xFF29B6F6);

  // --- Pink Theme (Chat, Sakura) ---
  static const Color pinkLightest = Color(0xFFFCE4EC);
  static const Color pinkLight = Color(0xFFF8BBD0);
  static const Color pinkMedium = Color(0xFFF48FB1);
  static const Color pinkDark = Color(0xFFEC407A);
  static const Color pinkDarker = Color(0xFFE91E63);
  static const Color pinkDarkest = Color(0xFFC2185B);

  // --- Orange/Amber Theme (Credits) ---
  static const Color orangeLightest = Color(0xFFFFF3E0);
  static const Color orangeLight = Color(0xFFFFE0B2);
  static const Color orangeMedium = Color(0xFFFFB74D);
  static const Color orangeDark = Color(0xFFFF9800);
  static const Color amberLight = Color(0xFFFFD54F);
  static const Color amberMedium = Color(0xFFFFCA28);
  static const Color yellowLight = Color(0xFFFFF59D);
  static const Color yellowMedium = Color(0xFFFFEE58);

  // --- Red Theme ---
  static const Color redLightest = Color(0xFFFFCDD2);
  static const Color redMedium = Color(0xFFEF5350);

  // --- Purple Theme (Settings, Profile) ---
  static const Color purpleLightest = Color(0xFFE8EAF6);
  static const Color purpleLight = Color(0xFFC5CAE9);
  static const Color purpleMedium = Color(0xFF9FA8DA);
  static const Color purpleDark = Color(0xFF7E57C2);
  static const Color purpleDarker = Color(0xFF5E35B1);
  static const Color purpleNavy = Color(0xFF263292);
  static const Color purpleBg = Color(0xFFE0DFF1);

  // --- Brown Theme (Shop) ---
  static const Color brownMedium = Color(0xFFC7AFA1);

  // --- Shop Category Colors ---
  static const Color categoryClothes = Color(0xFFC76F69);
  static const Color categoryAccessories = Color(0xFFBFC769);
  static const Color categoryFurniture = Color(0xFF7AB388);
  static const Color categoryBackground = Color(0xFFB37A8A);
  static const Color categorySeason = Color(0xFF8F7AB3);

  // --- Neutral Colors ---
  static const Color backgroundWhite = Color(0xFFFEFEFE);
  static const Color textPrimary = Color(0xFF01020B);
  static const Color cardBackground = Color(0xFFEFE9E9);
  static const Color progressBarBg = Color(0xFFD3E5DC);
  static const Color progressBarTrack = Color(0xFFBDC9B4);
  static const Color lockedItem = Color(0xFFD9D9D9);

  // --- Green Quest Card Colors ---
  static const Color questGreenLight = Color(0xFFC5E1A5);

  // --- Purple Quest Card Colors ---
  static const Color questPurpleLight = Color(0xFFCE93D8);
  static const Color questPurpleDark = Color(0xFFAB47BC);

  // --- Predefined Gradients ---
  static const List<Color> greenGradient = [greenLightest, greenLight, greenMediumLight];
  static const List<Color> blueGradient = [blueLightest, blueLight, blueMediumLight];
  static const List<Color> orangeGradient = [orangeLightest, orangeLight, orangeMedium];
  static const List<Color> pinkGradient = [pinkLightest, pinkLight, pinkMedium];
  static const List<Color> purpleGradient = [purpleLightest, purpleLight, purpleMedium];

  // --- Forest Background Gradient ---
  static const List<Color> forestGradient = [greenAccent, greenDarker, greenDark, greenMedium];

  // --- Beach Background Gradient ---
  static const List<Color> beachGradient = [blueSky, blueSkyDark, yellowLight, yellowMedium];

  // --- Space Background Gradient ---
  static const List<Color> spaceGradient = [blueNavy, blueNavyMedium, blueDark, blueNavyLight];

  // --- Sakura Background Gradient ---
  static const List<Color> sakuraGradient = [pinkLightest, pinkLight, pinkMedium];
}
