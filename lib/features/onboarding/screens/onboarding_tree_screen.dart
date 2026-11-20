import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumina/features/home/widgets/tree/growing_memory_tree.dart';
import 'package:lumina/features/home/widgets/tree/leaf_fly_animator.dart';

class OnboardingTreeScreen extends StatefulWidget {
  final VoidCallback onContinue;
  const OnboardingTreeScreen({super.key, required this.onContinue});

  @override
  State<OnboardingTreeScreen> createState() => _OnboardingTreeScreenState();
}

class _OnboardingTreeScreenState extends State<OnboardingTreeScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final GlobalKey _treeKey = GlobalKey();
  final FocusNode _focusNode = FocusNode();

  int _leafCount = 0;
  bool _isAnimating = false;
  bool _hasAnswered = false;
  bool _hasStartedTyping = false;

  late final AnimationController _staggerAc = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3000),
  )..forward();

  late final AnimationController _pulseAc = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final Animation<double> _titleFade = CurvedAnimation(
    parent: _staggerAc,
    curve: const Interval(0.0, 0.18, curve: Curves.easeOut),
  );
  late final Animation<double> _subtitleFade = CurvedAnimation(
    parent: _staggerAc,
    curve: const Interval(0.15, 0.30, curve: Curves.easeOut),
  );
  late final Animation<double> _treeFade = CurvedAnimation(
    parent: _staggerAc,
    curve: const Interval(0.28, 0.50, curve: Curves.easeOut),
  );
  late final Animation<double> _fieldFade = CurvedAnimation(
    parent: _staggerAc,
    curve: const Interval(0.52, 0.70, curve: Curves.easeOut),
  );
  late final Animation<double> _buttonFade = CurvedAnimation(
    parent: _staggerAc,
    curve: const Interval(0.72, 0.88, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      if (_textController.text.isNotEmpty && !_hasStartedTyping) {
        setState(() => _hasStartedTyping = true);
      } else if (_textController.text.isEmpty && _hasStartedTyping) {
        setState(() => _hasStartedTyping = false);
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _staggerAc.dispose();
    _pulseAc.dispose();
    super.dispose();
  }

  Future<void> _onAdd() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isAnimating || _hasAnswered) return;

    _focusNode.unfocus();
    setState(() => _isAnimating = true);

    await Future.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;

    final treeContext = _treeKey.currentContext;
    final treeBox = treeContext?.findRenderObject() as RenderBox?;

    if (treeBox == null || !treeBox.hasSize) {
      setState(() {
        _leafCount++;
        _isAnimating = false;
        _hasAnswered = true;
      });
      return;
    }

    final treeRect = treeBox.localToGlobal(Offset.zero) & treeBox.size;
    final int targetIndex = _leafCount;

    setState(() => _hasAnswered = true);
    _textController.clear();

    LeafFlyAnimator.fly(
      context: context,
      nextLeafIndex: targetIndex,
      treeRect: treeRect,
      onComplete: () {
        if (!mounted) return;
        setState(() {
          _leafCount++;
          _isAnimating = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(28, 8, 28, bottomInset + 16),
      child: Column(
        children: [
          // ── Title ────────────────────────────────────────────
          FadeTransition(
            opacity: _titleFade,
            child: Text(
              'Plant your memory',
              textAlign: TextAlign.center,
              style: GoogleFonts.fraunces(
                fontSize: 28,
                height: 1.2,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF3B251B),
              ),
            ),
          ),

          const SizedBox(height: 4),

          // ── Subtitle ─────────────────────────────────────────
          FadeTransition(
            opacity: _subtitleFade,
            child: Text(
              'Save Somthing and watch it grow on your tree.',
              textAlign: TextAlign.center,
              style: GoogleFonts.lora(
                fontStyle: FontStyle.italic,
                fontSize: 13,
                height: 1.5,
                color: const Color(0xFF6B5D4C),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── Tree ─────────────────────────────────────────────
          FadeTransition(
            opacity: _treeFade,
            child: SizedBox(
              key: _treeKey,
              height: 200,
              child: GrowingMemoryTree(
                entryCount: _leafCount,
                maxLeaves: 96,
                height: 200,
                animateNewLeaves: false,
                deletedAnchorIndices: const {},
                skippedAnchorIndices: const {},
              ),
            ),
          ),

          const SizedBox(height: 10),

          if (!_hasAnswered) ...[
            const SizedBox(height: 10),

            // ── Answer field ──────────────────────────────────
            FadeTransition(
              opacity: _fieldFade,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  AnimatedBuilder(
                    animation: _pulseAc,
                    builder: (context, child) {
                      final glow = _hasStartedTyping ? 0.0 : _pulseAc.value;
                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF3E8),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Color.lerp(
                              const Color(0xFFCCB98A).withOpacity(0.8),
                              const Color(0xFF8B6A4A),
                              glow,
                            )!,
                            width: 1.0 + glow * 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFB8904F,
                              ).withOpacity(0.18 * glow),
                              blurRadius: 12 * glow,
                              spreadRadius: 2 * glow,
                            ),
                          ],
                        ),
                        child: child,
                      );
                    },
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      maxLines: 3,
                      minLines: 3,
                      style: GoogleFonts.lora(
                        fontSize: 13.5,
                        color: const Color(0xFF3B251B),
                        height: 1.55,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Write Something here…',
                        hintStyle: GoogleFonts.lora(
                          fontSize: 13.5,
                          color: const Color(0xFFB0956E),
                          fontStyle: FontStyle.italic,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ── Button ────────────────────────────────────────
            FadeTransition(
              opacity: _buttonFade,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  AnimatedBuilder(
                    animation: _pulseAc,
                    builder: (context, child) {
                      final glow = _hasStartedTyping ? _pulseAc.value : 0.0;
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF3B251B,
                              ).withOpacity(0.35 * glow),
                              blurRadius: 14 * glow,
                              spreadRadius: 1 * glow,
                            ),
                          ],
                        ),
                        child: child,
                      );
                    },
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isAnimating ? null : _onAdd,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B251B),
                          disabledBackgroundColor: const Color(
                            0xFF3B251B,
                          ).withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isAnimating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Plant this memory',
                                style: GoogleFonts.cormorantGaramond(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              'Every answer grows your tree 🌿',
              textAlign: TextAlign.center,
              style: GoogleFonts.lora(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: const Color(0xFF8B6A4A),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: widget.onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B251B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Continue',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HandPointer extends StatelessWidget {
  final Animation<double> pulse;
  const _HandPointer({required this.pulse});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, pulse.value * 8),
          child: const Text('👆', style: TextStyle(fontSize: 28)),
        );
      },
    );
  }
}
