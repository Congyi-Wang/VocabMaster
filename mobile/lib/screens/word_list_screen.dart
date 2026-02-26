import 'package:flutter/material.dart';
import '../models/vocabulary.dart';
import '../models/app_theme.dart';
import '../services/tts_service.dart';

class WordListScreen extends StatefulWidget {
  final List<VocabularyEntry> vocabulary;
  final AppThemeData theme;

  const WordListScreen({
    super.key,
    required this.vocabulary,
    required this.theme,
  });

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  final TtsService _tts = TtsService();
  String _searchQuery = '';

  List<VocabularyEntry> get _filtered {
    if (_searchQuery.isEmpty) return widget.vocabulary;
    final q = _searchQuery.toLowerCase();
    return widget.vocabulary
        .where((e) =>
            e.word.toLowerCase().contains(q) ||
            e.meaning.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Word List (${widget.vocabulary.length})'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search words...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: t.surface,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),

          // Word list
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final entry = _filtered[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    title: Text(
                      entry.word,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: t.wordColor,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (entry.pronunciation.isNotEmpty)
                          Text(entry.pronunciation,
                              style: TextStyle(color: t.sentenceColor)),
                        Text(entry.meaning,
                            style: TextStyle(color: t.meaningColor)),
                        if (entry.exampleSentence.isNotEmpty)
                          Text(
                            entry.exampleSentence,
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: t.sentenceColor,
                            ),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.volume_up, color: t.buttonColor),
                          onPressed: () => _tts.speakWord(entry.word),
                          tooltip: 'Pronounce word',
                        ),
                        IconButton(
                          icon:
                              Icon(Icons.record_voice_over, color: t.accent),
                          onPressed: entry.exampleSentence.isNotEmpty
                              ? () =>
                                  _tts.speakSentence(entry.exampleSentence)
                              : null,
                          tooltip: 'Read sentence',
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
