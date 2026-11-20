import 'package:flutter/material.dart';

class OpenButtonInteraction extends StatefulWidget {
  final bool isUnlocked;
  final String label;
  final Color tileBg;
  final Color tileBorder;
  final Color textColor;
  final Color accentColor;
  final Color statusGreen;
  final VoidCallback onTap;

  const OpenButtonInteraction({
    super.key,
    required this.isUnlocked,
    required this.label,
    required this.tileBg,
    required this.tileBorder,
    required this.textColor,
    required this.accentColor,
    required this.statusGreen,
    required this.onTap,
  });

  @override
  State<OpenButtonInteraction> createState() => _OpenButtonInteractionState();
}

class _OpenButtonInteractionState extends State<OpenButtonInteraction>
    with SingleTickerProviderStateMixin {
  // ── Continuous glow when unlocked ──────────────────────────────
  late final AnimationController _glowController;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _glow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isUnlocked) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(OpenButtonInteraction oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isUnlocked && !_glowController.isAnimating) {
      _glowController.repeat(reverse: true);
    } else if (!widget.isUnlocked) {
      _glowController.stop();
      _glowController.value = 0;
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _glow,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: widget.tileBg,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Color.lerp(
                  widget.tileBorder,
                  widget.accentColor,
                  widget.isUnlocked ? _glow.value : 0,
                )!,
                width: widget.isUnlocked ? 1 + _glow.value : 1,
              ),
              boxShadow: widget.isUnlocked
                  ? [
                      BoxShadow(
                        color: widget.accentColor.withOpacity(
                          _glow.value * 0.4,
                        ),
                        blurRadius: 16 * _glow.value,
                        spreadRadius: 2 * _glow.value,
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 21,
                  color: widget.statusGreen,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: widget.textColor,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: widget.accentColor,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}