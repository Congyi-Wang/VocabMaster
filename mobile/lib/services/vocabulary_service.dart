import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import '../models/vocabulary.dart';
import '../models/app_theme.dart';

class VocabularyService {
  /// Parse a plain text vocabulary file.
  /// Supports: word | meaning, word\tmeaning, or just word per line.
  static List<VocabularyEntry> parseTxtFile(String content) {
    final entries = <VocabularyEntry>[];
    for (var line in content.split('\n')) {
      line = line.trim();
      if (line.isEmpty || line.startsWith('#')) continue;

      String word;
      String meaning = '';
      String pronunciation = '';
      String sentence = '';

      final parts = line.contains('|')
          ? line.split('|').map((e) => e.trim()).toList()
          : line.split('\t').map((e) => e.trim()).toList();

      word = parts[0];
      if (parts.length > 1) pronunciation = parts[1];
      if (parts.length > 2) meaning = parts[2];
      if (parts.length > 3) sentence = parts[3];

      entries.add(VocabularyEntry(
        word: word,
        pronunciation: pronunciation,
        meaning: meaning,
        exampleSentence: sentence,
      ));
    }
    return entries;
  }

  /// Parse vocabulary from JSON content.
  static List<VocabularyEntry> parseJsonFile(String content) {
    final data = jsonDecode(content);
    final list = data['vocabulary'] as List;
    return list.map((e) => VocabularyEntry.fromJson(e)).toList();
  }

  /// Load a theme zip file. Returns (theme, vocabulary).
  static Future<({AppThemeData theme, List<VocabularyEntry> vocabulary})>
      loadThemeZip(File zipFile) async {
    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    AppThemeData? theme;
    List<VocabularyEntry>? vocabulary;

    for (final file in archive) {
      if (file.isFile) {
        final content = utf8.decode(file.content as List<int>);

        if (file.name == 'theme.json') {
          theme = AppThemeData.fromJson(jsonDecode(content));
        } else if (file.name == 'vocabulary.json') {
          vocabulary = parseJsonFile(content);
        }

        // Extract asset files to local storage
        if (file.name.startsWith('assets/')) {
          final dir = await getApplicationDocumentsDirectory();
          final outFile = File('${dir.path}/theme_assets/${file.name}');
          await outFile.parent.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
        }
      }
    }

    return (
      theme: theme ?? AppThemeData.defaultTheme(),
      vocabulary: vocabulary ?? [],
    );
  }
}
