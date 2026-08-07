import 'package:flutter/material.dart';

/// Placeholder screen for the learning module.
///
/// Will be fully implemented in Phase 2.
class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key, required this.type});

  /// The kana type — "hiragana" or "katakana".
  final String type;

  @override
  Widget build(BuildContext context) {
    final isHiragana = type == 'hiragana';

    return Scaffold(
      appBar: AppBar(
        title: Text(isHiragana ? 'Hiragana' : 'Katakana'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isHiragana ? 'あ' : 'ア',
              style: const TextStyle(fontSize: 72),
            ),
            const SizedBox(height: 16),
            Text(
              '${isHiragana ? 'Hiragana' : 'Katakana'} lessons coming soon',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
