import 'package:flutter/material.dart';

class AppThemeData {
  final String name;
  final String description;
  final String style;
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color textColor;
  final Color accent;
  final Color wordColor;
  final Color meaningColor;
  final Color sentenceColor;
  final Color buttonColor;
  final Color buttonText;

  AppThemeData({
    required this.name,
    this.description = '',
    this.style = 'light',
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.textColor,
    required this.accent,
    required this.wordColor,
    required this.meaningColor,
    required this.sentenceColor,
    required this.buttonColor,
    required this.buttonText,
  });

  factory AppThemeData.fromJson(Map<String, dynamic> json) {
    final colors = json['colors'] ?? {};
    return AppThemeData(
      name: json['name'] ?? 'Default',
      description: json['description'] ?? '',
      style: json['style'] ?? 'light',
      primary: _parseColor(colors['primary'] ?? '#2196F3'),
      secondary: _parseColor(colors['secondary'] ?? '#757575'),
      background: _parseColor(colors['background'] ?? '#FFFFFF'),
      surface: _parseColor(colors['surface'] ?? '#F5F5F5'),
      textColor: _parseColor(colors['text'] ?? '#212121'),
      accent: _parseColor(colors['accent'] ?? '#FF9800'),
      wordColor: _parseColor(colors['word_color'] ?? '#1565C0'),
      meaningColor: _parseColor(colors['meaning_color'] ?? '#212121'),
      sentenceColor: _parseColor(colors['sentence_color'] ?? '#455A64'),
      buttonColor: _parseColor(colors['button_color'] ?? '#2196F3'),
      buttonText: _parseColor(colors['button_text'] ?? '#FFFFFF'),
    );
  }

  static Color _parseColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  ThemeData toFlutterTheme() {
    final brightness = style == 'dark' ? Brightness.dark : Brightness.light;
    return ThemeData(
      brightness: brightness,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      cardColor: surface,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: buttonText,
        secondary: secondary,
        onSecondary: buttonText,
        error: Colors.red,
        onError: Colors.white,
        surface: surface,
        onSurface: textColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: buttonText,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: buttonText,
      ),
    );
  }

  static AppThemeData defaultTheme() {
    return AppThemeData(
      name: 'Simple & Clean',
      description: 'Default minimal theme',
      style: 'light',
      primary: const Color(0xFF2196F3),
      secondary: const Color(0xFF757575),
      background: const Color(0xFFFFFFFF),
      surface: const Color(0xFFF5F5F5),
      textColor: const Color(0xFF212121),
      accent: const Color(0xFFFF9800),
      wordColor: const Color(0xFF1565C0),
      meaningColor: const Color(0xFF212121),
      sentenceColor: const Color(0xFF455A64),
      buttonColor: const Color(0xFF2196F3),
      buttonText: const Color(0xFFFFFFFF),
    );
  }
}
