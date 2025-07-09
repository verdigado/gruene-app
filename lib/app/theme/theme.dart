import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeColors {
  // Primary Green Dark/State Hover Green (#005437)
  static const Color primary = Color(0xFF005437);

  // Secondary Light Green (#008939)
  static const Color secondary = Color(0xFF008939);

  // Tertiary Light Green (#46962B)
  static const Color tertiary = Color(0xFF46962B);

  // White (#FFFFFF)
  static const Color background = Color(0xFFFFFFFF);

  // Softer Grey (#F9FAFB)
  static const Color backgroundSecondary = Color(0xFFF9FAFB);

  // Dark Grey (#343433)
  static const Color text = Color(0xFF343433);

  // Light Grey (#CCE7D7)
  static const Color textLight = Color(0xFFCCE7D7);

  // Black (#000000)
  static const Color textDark = Color(0xFF000000);

  // Middle Grey (#9CABAF)
  static const Color textDisabled = Color(0xFF9CABAF);

  static const Color textWarning = Color(0xFFCB4040);

  static const Color textCancel = Color(0xFF0A84FF);

  static const Color alertBackground = Color(0xFF252525);

  static const Color focusAreaBaseColor = Color(0xFF3033A1);

  static const Color infoBackground = Color(0xFFFFF7C8);

  static const Color sun = Color(0xFFFFF17A);
}

class _ThemeTextStyles {
  static TextStyle displayMedium = TextStyle(
    fontFamily: 'GrueneType',
    fontSize: 18,
    fontWeight: FontWeight.w900,
    height: 1.6,
    letterSpacing: 0.02,
    color: ThemeColors.text,
  );
  static TextStyle displayLarge = displayMedium.copyWith(fontSize: 34, height: 1.2, letterSpacing: 0.03);

  static TextStyle headlineLarge = GoogleFonts.ptSans(
    textStyle: TextStyle(fontSize: 42, fontWeight: FontWeight.w700, height: 1, letterSpacing: 0.02),
  );

  static TextStyle titleMedium = GoogleFonts.ptSans(
    textStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      height: 1.3,
      letterSpacing: 0.02,
      color: ThemeColors.text,
    ),
  );
  static TextStyle titleLarge = titleMedium.copyWith(fontSize: 21);
  static TextStyle titleSmall = titleMedium.copyWith(fontSize: 16, letterSpacing: 0.01);

  static TextStyle bodyMedium = GoogleFonts.ptSans(
    textStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.6,
      letterSpacing: 0.02,
      color: ThemeColors.text,
    ),
  );

  static TextStyle bodyLarge = bodyMedium.copyWith(fontSize: 18, height: 1);

  static TextStyle labelSmall = GoogleFonts.ptSans(
    textStyle: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w400,
      height: 1.3,
      letterSpacing: 0.01,
      color: ThemeColors.text,
    ),
  );

  static TextStyle labelMedium = GoogleFonts.ptSans(
    textStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, height: 1.3, letterSpacing: 0.01),
  );

  static TextStyle labelLarge = GoogleFonts.ptSans(
    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.3, letterSpacing: 0.01),
  );
}

final WidgetStateProperty<Icon?> thumbIcon = WidgetStateProperty.resolveWith<Icon?>((Set<WidgetState> states) {
  if (states.contains(WidgetState.selected)) {
    return const Icon(Icons.check);
  }
  return null;
});

final WidgetStateProperty<Color?> trackColor = WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
  if (states.contains(WidgetState.selected)) {
    return ThemeColors.primary;
  }
  return ThemeColors.textDisabled;
});

final WidgetStateProperty<Color?> thumbColor = WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
  if (states.contains(WidgetState.selected)) {
    return null;
  }
  return ThemeColors.background;
});

final ThemeData appTheme = ThemeData.light().copyWith(
  primaryColor: ThemeColors.primary,
  disabledColor: ThemeColors.textDisabled,
  colorScheme: ThemeData.light().colorScheme.copyWith(
    primary: ThemeColors.primary,
    secondary: ThemeColors.secondary,
    tertiary: ThemeColors.tertiary,
    surface: ThemeColors.background,
    surfaceDim: ThemeColors.backgroundSecondary,
  ),
  textTheme: TextTheme(
    displayLarge: _ThemeTextStyles.displayLarge,
    displayMedium: _ThemeTextStyles.displayMedium,
    headlineLarge: _ThemeTextStyles.headlineLarge,
    titleLarge: _ThemeTextStyles.titleLarge,
    titleMedium: _ThemeTextStyles.titleMedium,
    titleSmall: _ThemeTextStyles.titleSmall,
    bodyLarge: _ThemeTextStyles.bodyLarge,
    bodyMedium: _ThemeTextStyles.bodyMedium,
    labelLarge: _ThemeTextStyles.labelLarge,
    labelMedium: _ThemeTextStyles.labelMedium,
    labelSmall: _ThemeTextStyles.labelSmall,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: ThemeColors.background,
    selectedItemColor: ThemeColors.primary,
    unselectedItemColor: ThemeColors.textDisabled,
    selectedLabelStyle: _ThemeTextStyles.labelSmall,
    unselectedLabelStyle: _ThemeTextStyles.labelSmall,
  ),
  scaffoldBackgroundColor: ThemeColors.backgroundSecondary,
  tabBarTheme: TabBarThemeData(
    indicatorColor: ThemeColors.primary,
    indicatorSize: TabBarIndicatorSize.tab,
    labelStyle: _ThemeTextStyles.titleMedium,
    unselectedLabelStyle: _ThemeTextStyles.titleMedium,
    labelColor: ThemeColors.primary,
  ),
  switchTheme: SwitchThemeData(
    thumbIcon: thumbIcon,
    trackColor: trackColor,
    thumbColor: thumbColor,
    trackOutlineWidth: WidgetStatePropertyAll(0),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderSide: BorderSide(color: ThemeColors.textLight, width: 1),
      borderRadius: BorderRadius.all(Radius.circular(5)),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: ThemeColors.textLight, width: 1),
      borderRadius: BorderRadius.all(Radius.circular(5)),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: ThemeColors.textLight, width: 1),
      borderRadius: BorderRadius.all(Radius.circular(5)),
    ),
  ),
  dividerTheme: DividerThemeData(color: ThemeColors.textLight, space: 0.5, thickness: 0.5),
  datePickerTheme: DatePickerThemeData(rangeSelectionBackgroundColor: ThemeColors.textDisabled),
);
