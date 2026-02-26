import 'package:flutter/material.dart';
import 'models/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const VocabMasterApp());
}

class VocabMasterApp extends StatefulWidget {
  const VocabMasterApp({super.key});

  @override
  State<VocabMasterApp> createState() => _VocabMasterAppState();
}

class _VocabMasterAppState extends State<VocabMasterApp> {
  AppThemeData _currentTheme = AppThemeData.defaultTheme();

  void _onThemeChanged(AppThemeData newTheme) {
    setState(() => _currentTheme = newTheme);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VocabMaster',
      debugShowCheckedModeBanner: false,
      theme: _currentTheme.toFlutterTheme(),
      home: HomeScreen(
        onThemeChanged: _onThemeChanged,
        currentTheme: _currentTheme,
      ),
    );
  }
}
