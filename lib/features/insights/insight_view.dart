import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/core/routes/constants/widgets/time_aware_background.dart';
import 'package:lumina/features/insights/insights_controller.dart';

class InsightsView extends StatelessWidget {
  const InsightsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InsightsController>();

    return TimeAwareBookBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: const Color(0xFF3B2F1E),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            'Emotion Insights',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3B2F1E),
              letterSpacing: -0.5,
            ),
          ),
          centerTitle: true,
        ),
        body: Obx(() {
          final _ = controller.emotionData.length;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Range toggle ──────────────────────────────
                _RangeToggle(controller: controller),
                const SizedBox(height: 28),

                // ── Chart or empty state ──────────────────────
                controller.hasData.value
                    ? _EmotionChart(controller: controller)
                    : _EmptyState(range: controller.selectedRange.value),

                const SizedBox(height: 32),

                // ── Legend ────────────────────────────────────
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ── Range Toggle ───────────────────────────────────────────────
class _RangeToggle extends StatelessWidget {
  final InsightsController controller;
  const _RangeToggle({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE8DDD0),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            _ToggleBtn(
              label: '7 Days',
              selected: controller.selectedRange.value == InsightRange.week,
              onTap: () => controller.setRange(InsightRange.week),
            ),
            _ToggleBtn(
              label: '30 Days',
              selected: controller.selectedRange.value == InsightRange.month,
              onTap: () => controller.setRange(InsightRange.month),
            ),
            _ToggleBtn(
              label: 'All Time',
              selected: controller.selectedRange.value == InsightRange.all,
              onTap: () => controller.setRange(InsightRange.all),
            ),
          ],
        ),
      );
    });
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleBtn({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF3B2F1E) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : const Color(0xFF7A6652),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Emotion Chart ──────────────────────────────────────────────
class _EmotionChart extends StatelessWidget {
  final InsightsController controller;
  const _EmotionChart({required this.controller});

  // Color per emotion family
  Color _colorFor(String emotion, double avgScore) {
    final base = _baseColor(emotion);
    // Brighter/more opaque for higher significance score
    final opacity = 0.4 + (avgScore / 10) * 0.6;
    return base.withOpacity(opacity.clamp(0.4, 1.0));
  }

  Color _baseColor(String emotion) {
    final e = emotion.toLowerCase();
    if (e.contains('joy') || e.contains('happy') || e.contains('excit')) {
      return const Color(0xFFF4A83A);
    }
    if (e.contains('grat') || e.contains('content') || e.contains('peace')) {
      return const Color(0xFF5BA65B);
    }
    if (e.contains('sad') || e.contains('grief') || e.contains('lone')) {
      return const Color(0xFF5B8DC8);
    }
    if (e.contains('anx') || e.contains('stress') || e.contains('fear')) {
      return const Color(0xFFD46A6A);
    }
    if (e.contains('anger') || e.contains('frust') || e.contains('rage')) {
      return const Color(0xFFB94040);
    }
    if (e.contains('love') || e.contains('affec') || e.contains('warm')) {
      return const Color(0xFFD4648A);
    }
    if (e.contains('pride') || e.contains('confid') || e.contains('achiev')) {
      return const Color(0xFF8B6BB1);
    }
    return const Color(0xFF9A8A7A); // neutral fallback
  }

  @override
  Widget build(BuildContext context) {
    final data = controller.emotionData;
    final maxCount = data.map((e) => e.count).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFE6).withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4C4B0), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B2F1E).withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your emotion pattern',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3B2F1E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Based on your tagged memories',
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF7A6652).withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 20),
          ...data.map((e) {
            final barFraction = maxCount > 0 ? e.count / maxCount : 0.0;
            final color = _baseColor(e.emotion);
            return Padding(
              key: ValueKey('${e.emotion}_${controller.selectedRange.value}'),
              padding: const EdgeInsets.only(bottom: 14),
              child: _EmotionBar(
                emotion: e.emotion,
                count: e.count,
                fraction: barFraction,
                color: color,
                avgScore: e.avgScore,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _EmotionBar extends StatefulWidget {
  final String emotion;
  final int count;
  final double fraction;
  final Color color;
  final double avgScore;

  const _EmotionBar({
    required this.emotion,
    required this.count,
    required this.fraction,
    required this.color,
    required this.avgScore,
  });

  @override
  State<_EmotionBar> createState() => _EmotionBarState();
}

class _EmotionBarState extends State<_EmotionBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.emotion[0].toUpperCase() + widget.emotion.substring(1);
    final memoryWord = widget.count == 1 ? 'memory' : 'memories';

    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF3B2F1E),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: AnimatedBuilder(
            animation: _anim,
            builder: (context, _) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth;
                  final barWidth = (maxWidth * widget.fraction * _anim.value)
                      .clamp(4.0, maxWidth);
                  return Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // Background track
                      Container(
                        height: 36,
                        width: maxWidth,
                        decoration: BoxDecoration(
                          color: widget.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      // Filled bar
                      Container(
                        height: 36,
                        width: barWidth,
                        decoration: BoxDecoration(
                          color: widget.color,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      // Count label inside bar
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          '${widget.count} $memoryWord',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: widget.fraction > 0.35
                                ? Colors.white
                                : widget.color,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Legend ─────────────────────────────────────────────────────
class _Legend extends StatelessWidget {
  final InsightsController controller;
  const _Legend({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFE6).withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4C4B0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What the score means',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3B2F1E),
            ),
          ),
          const SizedBox(height: 10),
          _legendRow('1–3', 'Routine moment', const Color(0xFF9A8A7A), 0.5),
          _legendRow('4–6', 'Notable memory', const Color(0xFF9A8A7A), 0.7),
          _legendRow(
            '7–10',
            'Life-changing event',
            const Color(0xFF9A8A7A),
            1.0,
          ),
        ],
      ),
    );
  }

  Widget _legendRow(String score, String label, Color color, double opacity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 10,
            decoration: BoxDecoration(
              color: color.withOpacity(opacity),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$score — $label',
            style: const TextStyle(fontSize: 12, color: Color(0xFF5A4A3A)),
          ),
        ],
      ),
    );
  }
}

// ── Empty State ────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final InsightRange range;
  const _EmptyState({required this.range});

  String get _rangeLabel {
    switch (range) {
      case InsightRange.week:
        return 'the last 7 days';
      case InsightRange.month:
        return 'the last 30 days';
      case InsightRange.all:
        return 'any time yet';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFE6).withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4C4B0)),
      ),
      child: Column(
        children: [
          const Text('🌱', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 16),
          Text(
            'No memories tagged for $_rangeLabel.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3B2F1E),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Write a memory and AI will tag your emotions automatically.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF7A6652),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
