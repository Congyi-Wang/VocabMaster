import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/app_theme.dart';
import '../services/vocabulary_service.dart';

class SettingsScreen extends StatelessWidget {
  final ValueChanged<AppThemeData> onThemeChanged;
  final AppThemeData currentTheme;

  const SettingsScreen({
    super.key,
    required this.onThemeChanged,
    required this.currentTheme,
  });

  Future<void> _loadThemeFromZip(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final loaded = await VocabularyService.loadThemeZip(file);
    onThemeChanged(loaded.theme);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Theme "${loaded.theme.name}" applied!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Current theme info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Current Theme',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Name: ${currentTheme.name}'),
                  Text('Style: ${currentTheme.style}'),
                  Text('Description: ${currentTheme.description}'),
                  const SizedBox(height: 12),
                  // Color preview
                  Wrap(
                    spacing: 8,
                    children: [
                      _colorChip('Primary', currentTheme.primary),
                      _colorChip('Accent', currentTheme.accent),
                      _colorChip('Background', currentTheme.background),
                      _colorChip('Word', currentTheme.wordColor),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Load theme
          ElevatedButton.icon(
            onPressed: () => _loadThemeFromZip(context),
            icon: const Icon(Icons.palette),
            label: const Text('Load Theme from ZIP'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
          ),
          const SizedBox(height: 8),

          // Reset to default
          OutlinedButton.icon(
            onPressed: () {
              onThemeChanged(AppThemeData.defaultTheme());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Theme reset to default')),
              );
            },
            icon: const Icon(Icons.restore),
            label: const Text('Reset to Default Theme'),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'VocabMaster v1.0.0',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _colorChip(String label, Color color) {
    return Chip(
      avatar: CircleAvatar(backgroundColor: color),
      label: Text(label),
    );
  }
}
