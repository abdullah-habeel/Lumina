import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lumina/core/controller/journal_controller.dart';
import 'package:lumina/core/routes/constants/app_images.dart';
import 'package:lumina/core/service/ai_service.dart';
import 'package:lumina/core/service/pattern_service.dart';
import 'package:lumina/features/time_capsule/model/time_capsule_model.dart';

class TimeCapsuleOpenView extends StatefulWidget {
  final TimeCapsuleModel capsule;

  const TimeCapsuleOpenView({super.key, required this.capsule});

  @override
  State<TimeCapsuleOpenView> createState() => _TimeCapsuleOpenViewState();
}

class _TimeCapsuleOpenViewState extends State<TimeCapsuleOpenView> {
  final _aiService = AiService();
  final _patternService = PatternService();

  String? _revealText;
  bool _isLoadingReveal = false;
  bool _revealRequested = false;
  String? _revealError;

  Future<void> _generateReveal() async {
    setState(() {
      _isLoadingReveal = true;
      _revealRequested = true;
      _revealError = null;
    });

    try {
      final journalController = Get.find<JournalController>();
      final allEntries = journalController.entries;

      // Memories written after sealing
      final memoriesSinceSealing = allEntries
          .where((e) => e.date.isAfter(widget.capsule.sealedDate))
          .where((e) => e.body != null && e.body!.trim().isNotEmpty)
          .map((e) => {'question': e.question, 'answer': e.body ?? ''})
          .toList();

      // Current pattern
      final currentPattern = _patternService.computePattern(allEntries);

      // Pattern at sealing — use locked snapshot or fallback to empty
      final patternAtSealing =
          widget.capsule.patternAtSealing ?? <String, dynamic>{
            'totalMemories': 0,
            'topPeople': 'none yet',
            'topEmotions': 'none yet',
            'topThemes': 'none yet',
            'highSignificanceCount': 0,
          };

      final reveal = await _aiService.generateCapsuleReveal(
        originalMemory: widget.capsule.title,
        patternAtSealing: patternAtSealing,
        memoriesSinceSealing: memoriesSinceSealing,
        currentPattern: currentPattern,
      );

      setState(() {
        _revealText = reveal;
      });
    } catch (e) {
      setState(() {
        _revealError = 'Could not generate your reveal. Please try again.';
      });
    } finally {
      setState(() {
        _isLoadingReveal = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: 0.7,
            child: Image.asset(AppImages.timeCapsuleBg, fit: BoxFit.cover),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top bar ──────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Color(0xff3E2E1A),
                        ),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 8),

                          // ── Sealed date ──────────────────────
                          Text(
                            DateFormat('MMMM d, yyyy')
                                .format(widget.capsule.sealedDate)
                                .toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'Lora',
                              fontSize: 13,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff6B5D4B),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ── Greeting ─────────────────────────
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Dear future me,',
                              style: TextStyle(
                                fontFamily: 'PlayfairDisplay',
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w600,
                                fontSize: 26,
                                color: Color(0xff3E2E1A),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ── Original message ─────────────────
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.capsule.title,
                              style: const TextStyle(
                                fontFamily: 'Lora',
                                fontStyle: FontStyle.italic,
                                fontSize: 16,
                                height: 1.7,
                                color: Color(0xff3E2E1A),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // ── Sign off ─────────────────────────
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'With love,\nYour past self',
                              style: TextStyle(
                                fontFamily: 'PlayfairDisplay',
                                fontStyle: FontStyle.italic,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                height: 1.5,
                                color: Color(0xff3E2E1A),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // ── Divider ──────────────────────────
                          const Icon(
                            Icons.spa_outlined,
                            size: 22,
                            color: Color(0xff8D7B69),
                          ),
                          const SizedBox(height: 28),

                          // ── AI Reveal section ─────────────────
                          if (!_revealRequested) ...[
                            _RevealButton(onPressed: _generateReveal),
                          ] else if (_isLoadingReveal) ...[
                            const _RevealLoading(),
                          ] else if (_revealError != null) ...[
                            _RevealError(
                              error: _revealError!,
                              onRetry: _generateReveal,
                            ),
                          ] else if (_revealText != null) ...[
                            _RevealCard(revealText: _revealText!),
                          ],

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reveal Button ───────────────────────────────────────────────

class _RevealButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _RevealButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'See how you have changed',
          style: TextStyle(
            fontFamily: 'Lora',
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: const Color(0xff6B5D4B),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff3E2E1A),
              foregroundColor: const Color(0xffF4EBDD),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Reveal My Journey',
              style: TextStyle(
                fontFamily: 'Lora',
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Reveal Loading ──────────────────────────────────────────────

class _RevealLoading extends StatelessWidget {
  const _RevealLoading();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        CircularProgressIndicator(color: Color(0xff3E2E1A)),
        SizedBox(height: 16),
        Text(
          'Comparing who you were\nto who you are now...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Lora',
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: Color(0xff6B5D4B),
          ),
        ),
      ],
    );
  }
}

// ── Reveal Error ────────────────────────────────────────────────

class _RevealError extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _RevealError({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          error,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Lora',
            fontSize: 14,
            color: Color(0xff6B5D4B),
          ),
        ),
        const SizedBox(height: 14),
        TextButton(
          onPressed: onRetry,
          child: const Text(
            'Try again',
            style: TextStyle(
              fontFamily: 'Lora',
              color: Color(0xff3E2E1A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Reveal Card ─────────────────────────────────────────────────

class _RevealCard extends StatelessWidget {
  final String revealText;
  const _RevealCard({required this.revealText});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xffF4EBDD).withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xff8D7B69).withOpacity(0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Journey',
            style: TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xff3E2E1A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'From then to now — written by AI',
            style: TextStyle(
              fontFamily: 'Lora',
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Color(0xff8D7B69),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            revealText,
            style: const TextStyle(
              fontFamily: 'Lora',
              fontSize: 15,
              height: 1.8,
              color: Color(0xff3E2E1A),
            ),
          ),
        ],
      ),
    );
  }
}