// lib/theme/app_themes.dart - Green Primary Theme (Matching iOS App)
import 'package:flutter/material.dart';

class AppThemes {
  // MARK: - Primary Colors (Matching your iOS App)
  static const Color primaryGreen = Color(0xFF34C759);      // Main green như iOS app
  static const Color primaryGreenDark = Color(0xFF30A14E);
  static const Color primaryGreenLight = Color(0xFF4CD964);
  
  // MARK: - Secondary Colors  
  static const Color secondary = Color(0xFF007AFF);         // Blue for secondary
  static const Color secondaryDark = Color(0xFF0051D0);
  
  // MARK: - iOS System Colors (Perfect Match với iOS)
  static const Color systemRed = Color(0xFFFF3B30);
  static const Color systemOrange = Color(0xFFFF9500);
  static const Color systemYellow = Color(0xFFFFCC00);
  static const Color systemGreen = Color(0xFF34C759);       // Same as primary
  static const Color systemTeal = Color(0xFF5AC8FA);
  static const Color systemBlue = Color(0xFF007AFF);
  static const Color systemIndigo = Color(0xFF5856D6);
  static const Color systemPurple = Color(0xFFAF52DE);
  static const Color systemPink = Color(0xFFFF2D92);
  
  // MARK: - iOS Gray Colors
  static const Color systemGray = Color(0xFF8E8E93);
  static const Color systemGray2 = Color(0xFFAEAEB2);
  static const Color systemGray3 = Color(0xFFC7C7CC);
  static const Color systemGray4 = Color(0xFFD1D1D6);
  static const Color systemGray5 = Color(0xFFE5E5EA);
  static const Color systemGray6 = Color(0xFFF2F2F7);

  // MARK: - Learning Level Colors (như iOS app)
  static const Color levelBeginner = systemGreen;    // Green cho beginner
  static const Color levelIntermediate = systemOrange; // Orange cho intermediate  
  static const Color levelAdvanced = systemRed;      // Red cho advanced
  static const Color levelA1 = systemGreen;
  static const Color levelA2 = systemTeal;
  static const Color levelB1 = systemBlue;
  static const Color levelB2 = systemIndigo;
  static const Color levelC1 = systemPurple;
  static const Color levelC2 = systemPink;
  
  // MARK: - Exercise Type Colors (như iOS app)
  static const Color multipleChoice = systemBlue;
  static const Color fillBlank = systemGreen;
  static const Color listening = systemPurple;         // Purple cho listening
  static const Color translation = systemOrange;
  static const Color speaking = systemRed;             // Red cho speaking/writing
  static const Color reading = systemTeal;
  static const Color vocabulary = systemBlue;          // Blue cho vocabulary
  static const Color mistakes = systemOrange;          // Orange cho mistakes
  
  // MARK: - Gamification Colors
  static const Color hearts = systemRed;
  static const Color xp = systemOrange;                // Orange cho XP
  static const Color streak = systemPurple;
  static const Color premium = systemYellow;
  static const Color goldColor = Color(0xFFFFD700);    // Gold cho rewards

  // MARK: - iOS Background Colors
  // Light Mode Backgrounds
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSecondaryBackground = Color(0xFFF2F2F7);
  static const Color lightTertiaryBackground = Color(0xFFFFFFFF);
  static const Color lightGroupedBackground = Color(0xFFF2F2F7);
  static const Color lightSecondaryGroupedBackground = Color(0xFFFFFFFF);
  
  // Dark Mode Backgrounds
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSecondaryBackground = Color(0xFF1C1C1E);
  static const Color darkTertiaryBackground = Color(0xFF2C2C2E);
  static const Color darkGroupedBackground = Color(0xFF000000);
  static const Color darkSecondaryGroupedBackground = Color(0xFF1C1C1E);

  // MARK: - iOS Label Colors
  // Light Mode Labels
  static const Color lightLabel = Color(0xFF000000);
  static const Color lightSecondaryLabel = Color(0xFF3C3C43);
  static const Color lightTertiaryLabel = Color(0xFF3C3C43);
  
  // Dark Mode Labels
  static const Color darkLabel = Color(0xFFFFFFFF);
  static const Color darkSecondaryLabel = Color(0xFFEBEBF5);
  static const Color darkTertiaryLabel = Color(0xFFEBEBF5);

  // MARK: - Light Theme (Green Primary)
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGreen,                    // Changed to green
      brightness: Brightness.light,
      primary: primaryGreen,                      // Green primary
      secondary: secondary,                       // Blue secondary
      error: systemRed,
      surface: lightSecondaryBackground,
      background: lightBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: lightLabel,
      onBackground: lightLabel,
    ),
    
    // MARK: - AppBar Theme (iOS style)
    appBarTheme: const AppBarTheme(
      backgroundColor: lightSecondaryBackground,
      foregroundColor: lightLabel,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: lightLabel,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        fontFamily: '-apple-system',            // iOS font
      ),
      iconTheme: IconThemeData(
        color: primaryGreen,                     // Green icons
        size: 22,
      ),
    ),
    
    // MARK: - Card Theme (iOS style với shadow nhẹ)
    cardTheme: CardThemeData(
      elevation: 0,
      color: lightBackground,
      shadowColor: Colors.black.withOpacity(0.08),   // Nhẹ như iOS
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),       // 15px như iOS
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    
    // MARK: - ElevatedButton Theme (Green primary)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,              // Green button
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          fontFamily: '-apple-system',
        ),
      ),
    ),
    
    // MARK: - TextButton Theme (Green primary)
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryGreen,              // Green text buttons
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          fontFamily: '-apple-system',
        ),
      ),
    ),
    
    // MARK: - Input Decoration Theme (iOS style)
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: systemGray4),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: systemGray4),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryGreen, width: 2), // Green focus
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: systemRed),
      ),
      filled: true,
      fillColor: lightBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: const TextStyle(
        color: systemGray,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      hintStyle: const TextStyle(
        color: systemGray,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),
    
    // MARK: - Bottom Navigation Bar Theme (Green selected)
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: lightSecondaryBackground,
      selectedItemColor: primaryGreen,              // Green selected
      unselectedItemColor: systemGray,
      elevation: 0,
      selectedLabelStyle: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        fontFamily: '-apple-system',
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        fontFamily: '-apple-system',
      ),
    ),
    
    // MARK: - Text Theme (iOS style)
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.bold,
        color: lightLabel,
        fontFamily: '-apple-system',
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: lightLabel,
        fontFamily: '-apple-system',
      ),
      displaySmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: lightLabel,
        fontFamily: '-apple-system',
      ),
      headlineLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: lightLabel,
        fontFamily: '-apple-system',
      ),
      headlineMedium: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: lightLabel,
        fontFamily: '-apple-system',
      ),
      headlineSmall: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: lightLabel,
        fontFamily: '-apple-system',
      ),
      bodyLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: lightLabel,
        fontFamily: '-apple-system',
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: lightLabel,
        fontFamily: '-apple-system',
      ),
      bodySmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: lightSecondaryLabel,
        fontFamily: '-apple-system',
      ),
    ),
    
    // MARK: - ListTile Theme (iOS style)
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      titleTextStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: lightLabel,
        fontFamily: '-apple-system',
      ),
      subtitleTextStyle: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: lightSecondaryLabel,
        fontFamily: '-apple-system',
      ),
    ),
    
    // MARK: - Scaffold Background
    scaffoldBackgroundColor: lightGroupedBackground,
  );

  // MARK: - Dark Theme (Green Primary)
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGreen,                    // Green seed
      brightness: Brightness.dark,
      primary: primaryGreen,                      // Green primary
      secondary: secondary,                       // Blue secondary
      error: systemRed,
      surface: darkSecondaryBackground,
      background: darkBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: darkLabel,
      onBackground: darkLabel,
    ),
    
    // MARK: - AppBar Theme (iOS Dark style)
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSecondaryBackground,
      foregroundColor: darkLabel,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: darkLabel,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        fontFamily: '-apple-system',
      ),
      iconTheme: IconThemeData(
        color: primaryGreen,                      // Green icons in dark
        size: 22,
      ),
    ),
    
    // MARK: - Card Theme (iOS Dark style)
    cardTheme: CardThemeData(
      elevation: 0,
      color: darkSecondaryBackground,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    
    // MARK: - ElevatedButton Theme (Green in dark)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,              // Green button in dark
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          fontFamily: '-apple-system',
        ),
      ),
    ),
    
    // MARK: - TextButton Theme (Green in dark)
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryGreen,              // Green text in dark
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          fontFamily: '-apple-system',
        ),
      ),
    ),
    
    // MARK: - Input Decoration Theme (iOS Dark style)
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: systemGray3),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: systemGray3),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryGreen, width: 2), // Green focus
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: systemRed),
      ),
      filled: true,
      fillColor: darkTertiaryBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: const TextStyle(
        color: systemGray2,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      hintStyle: const TextStyle(
        color: systemGray2,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),
    
    // MARK: - Bottom Navigation Bar Theme (Green selected in dark)
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: darkSecondaryBackground,
      selectedItemColor: primaryGreen,              // Green selected in dark
      unselectedItemColor: systemGray,
      elevation: 0,
      selectedLabelStyle: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        fontFamily: '-apple-system',
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        fontFamily: '-apple-system',
      ),
    ),
    
    // MARK: - Text Theme (iOS Dark style)
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.bold,
        color: darkLabel,
        fontFamily: '-apple-system',
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: darkLabel,
        fontFamily: '-apple-system',
      ),
      displaySmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: darkLabel,
        fontFamily: '-apple-system',
      ),
      headlineLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: darkLabel,
        fontFamily: '-apple-system',
      ),
      headlineMedium: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: darkLabel,
        fontFamily: '-apple-system',
      ),
      headlineSmall: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: darkLabel,
        fontFamily: '-apple-system',
      ),
      bodyLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: darkLabel,
        fontFamily: '-apple-system',
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: darkLabel,
        fontFamily: '-apple-system',
      ),
      bodySmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: darkSecondaryLabel,
        fontFamily: '-apple-system',
      ),
    ),
    
    // MARK: - ListTile Theme (iOS Dark style)
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      titleTextStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: darkLabel,
        fontFamily: '-apple-system',
      ),
      subtitleTextStyle: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: darkSecondaryLabel,
        fontFamily: '-apple-system',
      ),
    ),
    
    // MARK: - Scaffold Background
    scaffoldBackgroundColor: darkGroupedBackground,
  );
  
  // MARK: - Helper Methods
  
  // Get level color based on difficulty
  static Color getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
      case 'a1': 
        return levelBeginner;
      case 'intermediate':
      case 'a2':
      case 'b1': 
        return levelIntermediate;
      case 'advanced':
      case 'b2':
      case 'c1':
      case 'c2': 
        return levelAdvanced;
      default: 
        return primaryGreen;
    }
  }
  
  // Get exercise type color
  static Color getExerciseColor(String type) {
    switch (type.toLowerCase()) {
      case 'multiple_choice': 
        return multipleChoice;
      case 'fill_blank': 
        return fillBlank;
      case 'listening': 
        return listening;
      case 'translation': 
        return translation;
      case 'speaking':
      case 'writing': 
        return speaking;
      case 'reading': 
        return reading;
      case 'vocabulary':
        return vocabulary;
      case 'mistakes':
        return mistakes;
      default: 
        return primaryGreen;
    }
  }

  // Get progress color based on completion percentage
  static Color getProgressColor(double percentage) {
    if (percentage >= 1.0) {
      return systemGreen;           // Completed = Green
    } else if (percentage > 0) {
      return systemOrange;          // In progress = Orange  
    } else {
      return systemGray;            // Not started = Gray
    }
  }

  // Get difficulty color (như iOS app)
  static Color getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return systemGreen;
      case 'intermediate':
        return systemOrange;
      case 'advanced':
        return systemRed;
      default:
        return systemGreen;
    }
  }
}