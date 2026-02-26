import 'package:flutter/material.dart';
import '../models/vocabulary.dart';
import '../models/app_theme.dart';
import '../services/tts_service.dart';

class ReviewScreen extends StatefulWidget {
  final List<VocabularyEntry> vocabulary;
  final AppThemeData theme;

  const ReviewScreen({
    super.key,
    required this.vocabulary,
    required this.theme,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _currentIndex = 0;
  bool _showMeaning = false;
  final TtsService _tts = TtsService();

  VocabularyEntry get _current => widget.vocabulary[_currentIndex];
  int get _total => widget.vocabulary.length;

  void _next() {
    setState(() {
      _showMeaning = false;
      _currentIndex = (_currentIndex + 1) % _total;
    });
  }

  void _previous() {
    setState(() {
      _showMeaning = false;
      _currentIndex = (_currentIndex - 1 + _total) % _total;
    });
  }

  void _toggleMeaning() {
    setState(() => _showMeaning = !_showMeaning);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Review (${_currentIndex + 1}/$_total)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _total,
              color: t.accent,
              backgroundColor: t.surface,
            ),
            const SizedBox(height: 24),

            // Flashcard
            Expanded(
              child: GestureDetector(
                onTap: _toggleMeaning,
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity != null) {
                    if (details.primaryVelocity! < 0) _next();
                    if (details.primaryVelocity! > 0) _previous();
                  }
                },
                child: Card(
                  elevation: 4,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Word
                        Text(
                          _current.word,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: t.wordColor,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        // Pronunciation
                        if (_current.pronunciation.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            _current.pronunciation,
                            style: TextStyle(
                              fontSize: 18,
                              color: t.sentenceColor,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Meaning (tap to reveal)
                        if (_showMeaning) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: t.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _current.meaning,
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: t.meaningColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (_current.exampleSentence.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    _current.exampleSentence,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: t.sentenceColor,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ] else ...[
                          Text(
                            'Tap to reveal meaning',
                            style: TextStyle(
                              fontSize: 16,
                              color: t.sentenceColor.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // TTS Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _tts.speakWord(_current.word),
                    icon: const Icon(Icons.volume_up),
                    label: const Text('Word'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: t.buttonColor,
                      foregroundColor: t.buttonText,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _current.exampleSentence.isNotEmpty
                        ? () => _tts.speakSentence(_current.exampleSentence)
                        : null,
                    icon: const Icon(Icons.record_voice_over),
                    label: const Text('Sentence'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: t.accent,
                      foregroundColor: t.buttonText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _previous,
                  icon: Icon(Icons.arrow_back_ios, color: t.primary),
                  iconSize: 32,
                ),
                Text(
                  '${_currentIndex + 1} / $_total',
                  style: TextStyle(fontSize: 18, color: t.textColor),
                ),
                IconButton(
                  onPressed: _next,
                  icon: Icon(Icons.arrow_forward_ios, color: t.primary),
                  iconSize: 32,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
