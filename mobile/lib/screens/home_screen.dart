import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/vocabulary.dart';
import '../models/app_theme.dart';
import '../services/vocabulary_service.dart';
import 'review_screen.dart';
import 'word_list_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<AppThemeData> onThemeChanged;
  final AppThemeData currentTheme;

  const HomeScreen({
    super.key,
    required this.onThemeChanged,
    required this.currentTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<VocabularyEntry> _vocabulary = [];
  String _statusMessage = 'No vocabulary loaded';

  Future<void> _loadTxtFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );
    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final content = await file.readAsString();
    final entries = VocabularyService.parseTxtFile(content);

    setState(() {
      _vocabulary = entries;
      _statusMessage = 'Loaded ${entries.length} words from TXT';
    });
  }

  Future<void> _loadJsonFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final content = await file.readAsString();
    final entries = VocabularyService.parseJsonFile(content);

    setState(() {
      _vocabulary = entries;
      _statusMessage = 'Loaded ${entries.length} words from JSON';
    });
  }

  Future<void> _loadThemeZip() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final loaded = await VocabularyService.loadThemeZip(file);

    widget.onThemeChanged(loaded.theme);

    setState(() {
      if (loaded.vocabulary.isNotEmpty) {
        _vocabulary = loaded.vocabulary;
      }
      _statusMessage =
          'Theme "${loaded.theme.name}" loaded with ${loaded.vocabulary.length} words';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.currentTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('VocabMaster'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SettingsScreen(
                  onThemeChanged: widget.onThemeChanged,
                  currentTheme: widget.currentTheme,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.menu_book, size: 48, color: theme.primary),
                    const SizedBox(height: 8),
                    Text(
                      _statusMessage,
                      style: TextStyle(fontSize: 16, color: theme.textColor),
                      textAlign: TextAlign.center,
                    ),
                    if (_vocabulary.isNotEmpty)
                      Text(
                        '${_vocabulary.length} words ready for review',
                        style: TextStyle(color: theme.sentenceColor),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Import buttons
            Text('Import Vocabulary',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.textColor)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _loadTxtFile,
                    icon: const Icon(Icons.text_snippet),
                    label: const Text('Load TXT'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _loadJsonFile,
                    icon: const Icon(Icons.data_object),
                    label: const Text('Load JSON'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _loadThemeZip,
              icon: const Icon(Icons.palette),
              label: const Text('Load Theme ZIP'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.accent,
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            if (_vocabulary.isNotEmpty) ...[
              Text('Study',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textColor)),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReviewScreen(
                      vocabulary: _vocabulary,
                      theme: theme,
                    ),
                  ),
                ),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Review'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WordListScreen(
                      vocabulary: _vocabulary,
                      theme: theme,
                    ),
                  ),
                ),
                icon: const Icon(Icons.list),
                label: const Text('Word List'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
