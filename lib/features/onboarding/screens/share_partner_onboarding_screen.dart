import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingSharePartnerScreen extends StatefulWidget {
  const OnboardingSharePartnerScreen({super.key});

  @override
  State<OnboardingSharePartnerScreen> createState() =>
      _OnboardingSharePartnerScreenState();
}

class _OnboardingSharePartnerScreenState
    extends State<OnboardingSharePartnerScreen> with TickerProviderStateMixin {
  // Two memory cards (yours + theirs) + the connecting heart badge
  late final AnimationController _card1Ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1900),
  );
  late final AnimationController _card2Ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1900),
  );
  late final AnimationController _linkAc = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final AnimationController _textAc = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  late final Animation<double> _card1Fade =
      CurvedAnimation(parent: _card1Ac, curve: Curves.easeOut);
  late final Animation<double> _card1Slide =
      CurvedAnimation(parent: _card1Ac, curve: Curves.easeOutCubic);

  late final Animation<double> _card2Fade =
      CurvedAnimation(parent: _card2Ac, curve: Curves.easeOut);
  late final Animation<double> _card2Slide =
      CurvedAnimation(parent: _card2Ac, curve: Curves.easeOutCubic);

  // Heart badge pops in with a little overshoot once both cards have landed
  late final Animation<double> _linkScale = CurvedAnimation(
    parent: _linkAc,
    curve: Curves.elasticOut,
  );
  late final Animation<double> _linkFade = CurvedAnimation(
    parent: _linkAc,
    curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
  );

  late final Animation<double> _titleFade = CurvedAnimation(
    parent: _textAc,
    curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
  );
  late final Animation<double> _bodyFade = CurvedAnimation(
    parent: _textAc,
    curve: const Interval(0.25, 0.7, curve: Curves.easeOut),
  );
  late final Animation<double> _pillsFade = CurvedAnimation(
    parent: _textAc,
    curve: const Interval(0.5, 0.85, curve: Curves.easeOut),
  );
  late final Animation<double> _noteFade = CurvedAnimation(
    parent: _textAc,
    curve: const Interval(0.72, 1.0, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _card1Ac.forward();
    await Future.delayed(const Duration(milliseconds: 720));
    _card2Ac.forward();
    await Future.delayed(const Duration(milliseconds: 550));
    _linkAc.forward();
    await Future.delayed(const Duration(milliseconds: 450));
    _textAc.forward();
  }

  @override
  void dispose() {
    _card1Ac.dispose();
    _card2Ac.dispose();
    _linkAc.dispose();
    _textAc.dispose();
    super.dispose();
  }

  Widget _buildCard(
    _MemoryCardData data,
    Animation<double> fade,
    Animation<double> slide,
  ) {
    return AnimatedBuilder(
      animation: fade,
      builder: (context, _) {
        return Opacity(
          opacity: fade.value,
          child: Transform.translate(
            offset: Offset(0, (1 - slide.value) * 40),
            child: _MemoryCard(data: data),
          ),
        );
      },
    );
  }

  

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 224,
              height: 232,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Your memory card — leaning left
                  Positioned(
                    left: 0,
                    top: 30,
                    child: Transform.rotate(
                      angle: -0.09,
                      child: _buildCard(
                        const _MemoryCardData(
                          emoji: '🌸',
                          label: 'Your memory',
                          sub: 'Kept safe, just for you',
                          spine: Color(0xFF8B4513),
                          bg: Color(0xFFF4D4B0),
                          textColor: Color(0xFF4A2008),
                          subColor: Color(0xFF7A3A18),
                        ),
                        _card1Fade,
                        _card1Slide,
                      ),
                    ),
                  ),
        
                  // Their memory card — leaning right, slightly forward
                  Positioned(
                    right: 0,
                    top: 12,
                    child: Transform.rotate(
                      angle: 0.09,
                      child: _buildCard(
                        const _MemoryCardData(
                          emoji: '🌷',
                          label: 'Shared with them',
                          sub: 'Now it belongs to two',
                          spine: Color(0xFF4A3580),
                          bg: Color(0xFFD8D0F0),
                          textColor: Color(0xFF1E1440),
                          subColor: Color(0xFF4A3580),
                        ),
                        _card2Fade,
                        _card2Slide,
                      ),
                    ),
                  ),
        
                  // Connecting heart badge — pops in once both cards have landed
                  AnimatedBuilder(
                    animation: _linkAc,
                    builder: (context, _) {
                      return Opacity(
                        opacity: _linkFade.value,
                        child: Transform.scale(
                          scale: _linkScale.value,
                          child: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFFAF3E8),
                              border: Border.all(
                                color: const Color(0xFFC9847A),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.14),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Text('💛', style: TextStyle(fontSize: 20)),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
        
            const SizedBox(height: 28),
        
            FadeTransition(
              opacity: _titleFade,
              child: Text(
                'Golden memories\ndeserve two hearts',
                textAlign: TextAlign.center,
                style: GoogleFonts.fraunces(
                  fontSize: 28,
                  height: 1.15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3B251B),
                ),
              ),
            ),
        
            const SizedBox(height: 14),
        
            FadeTransition(
              opacity: _bodyFade,
              child: Text(
                'Some memories aren\'t meant to be kept alone.',
                textAlign: TextAlign.center,
                style: GoogleFonts.lora(
                  fontSize: 14,
                   fontStyle: FontStyle.italic,
                  height: 1.6,
                  color: const Color(0xFF6B5D4C),
                ),
              ),
            ),
        
            const SizedBox(height: 22),
            
        
            
        
        
            
          ],
        ),
      ),
    );
  }
}

class _MemoryCardData {
  final String emoji;
  final String label;
  final String sub;
  final Color spine;
  final Color bg;
  final Color textColor;
  final Color subColor;

  const _MemoryCardData({
    required this.emoji,
    required this.label,
    required this.sub,
    required this.spine,
    required this.bg,
    required this.textColor,
    required this.subColor,
  });
}

class _MemoryCard extends StatelessWidget {
  final _MemoryCardData data;
  const _MemoryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 180,
      decoration: BoxDecoration(
        color: data.bg,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(10),
          bottomRight: Radius.circular(10),
          topLeft: Radius.circular(2),
          bottomLeft: Radius.circular(2),
        ),
        border: Border(
          left: BorderSide(color: data.spine, width: 14),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 10,
            offset: const Offset(3, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(
            data.label,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: data.textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.sub,
            style: GoogleFonts.lora(
              fontSize: 9.5,
              fontStyle: FontStyle.italic,
              color: data.subColor,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _SharePill extends StatelessWidget {
  final String label;
  const _SharePill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFD9CEBC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFB8A48C)),
      ),
      child: Text(
        label,
        style: GoogleFonts.cormorantGaramond(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF4A3020),
        ),
      ),
    );
  }
}