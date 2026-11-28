import 'package:lumina/core/routes/model/journel_entry_model.dart';

class PatternService {
  /// Reads all entries and their tags, returns a pattern summary map.
  /// Pure arithmetic — no AI involved.
  Map<String, dynamic> computePattern(List<JournalEntry> entries) {
    int totalMemories = entries.length;
    int highSignificanceCount = 0;

    final Map<String, int> peopleCounts = {};
    final Map<String, int> emotionCounts = {};
    final Map<String, int> themeCounts = {};
   final Map<String, int> keywordCounts = {};
final Map<String, int> inferenceSourceCounts = {};

    for (final entry in entries) {
      final tags = entry.tags;
      if (tags == null || tags.isEmpty) continue;

           // ── Significance ───────────────────────────────────────
      final significance = tags['significance'] as String? ?? '';
      if (significance == 'high') highSignificanceCount++;

      // ── Inference source ───────────────────────────────────
      final source = entry.inferenceSource;
      if (source != null && source.isNotEmpty && source != 'failed') {
        inferenceSourceCounts[source] = (inferenceSourceCounts[source] ?? 0) + 1;
      }
      // ── People ─────────────────────────────────────────────
      final people = tags['people'];
      if (people is List) {
        for (final p in people) {
          if (p is String && p.trim().isNotEmpty) {
            peopleCounts[p.trim()] = (peopleCounts[p.trim()] ?? 0) + 1;
          }
        }
      }

      // ── Emotions ───────────────────────────────────────────
      final emotions = tags['emotions'];
      if (emotions is List) {
        for (final e in emotions) {
          if (e is String && e.trim().isNotEmpty) {
            emotionCounts[e.trim()] = (emotionCounts[e.trim()] ?? 0) + 1;
          }
        }
      }

      // ── Themes ─────────────────────────────────────────────
      final themes = tags['themes'];
      if (themes is List) {
        for (final t in themes) {
          if (t is String && t.trim().isNotEmpty) {
            themeCounts[t.trim()] = (themeCounts[t.trim()] ?? 0) + 1;
          }
        }
      }

      // ── Keywords ───────────────────────────────────────────
      final keywords = tags['keywords'];
      if (keywords is List) {
        for (final k in keywords) {
          if (k is String && k.trim().isNotEmpty) {
            keywordCounts[k.trim()] = (keywordCounts[k.trim()] ?? 0) + 1;
          }
        }
      }
    }

    return {
      'totalMemories': totalMemories,
      'highSignificanceCount': highSignificanceCount,
      'topPeople': _topN(peopleCounts, 5),
      'topEmotions': _topN(emotionCounts, 5),
      'topThemes': _topN(themeCounts, 5),
       'topKeywords': _topN(keywordCounts, 10),
      'dominantInferenceSource': _dominantSource(inferenceSourceCounts),
    };
  }

    /// Returns the most common inference source across entries.
  String _dominantSource(Map<String, int> counts) {
    if (counts.isEmpty) return 'unknown';
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key; // 'on_device' or 'cloud'
  }

  /// Returns top N entries sorted by count, as a readable string.
  /// Example: "family (12), joy (8), growth (5)"
  String _topN(Map<String, int> counts, int n) {
    if (counts.isEmpty) return 'none yet';

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted
        .take(n)
        .map((e) => '${e.key} (${e.value})')
        .join(', ');
  }
}