import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumina/core/animation/floating_drag_wrapper.dart';
import 'package:lumina/core/routes/constants/widgets/day_light_colors.dart';
import 'package:lumina/features/chapter_detail/model/chapter_question_model.dart';
import 'package:lumina/features/home/widgets/sun_and_day_animation.dart';
import 'package:lumina/features/shared/widgets/share_card/shared_card_paint.dart';

import 'question_timeline_painter.dart';

class QuestionTimelineCard extends StatefulWidget {
  const QuestionTimelineCard({
    super.key,
    required this.question,
    required this.status,
    this.onTap,
    this.onShare,
    this.onConfirmDelete,
    this.onDelete,
    this.enableFloatingDrag = true,
  });

  final ChapterQuestionModel question;
  final QuestionStatus status;

  final VoidCallback? onTap;
  final VoidCallback? onShare;
  final Future<bool> Function()? onConfirmDelete;
  final Future<bool> Function()? onDelete;
  final bool enableFloatingDrag;

  @override
  State<QuestionTimelineCard> createState() => _QuestionTimelineCardState();
}

class _QuestionTimelineCardState extends State<QuestionTimelineCard>
    with TickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
    reverseDuration: const Duration(milliseconds: 260),
  );

  double _tapWidthFactor = 0.5;
  bool _deleting = false;

  double get _seed => (widget.question.question.hashCode % 1000) / 100;

  bool get isCompleted => widget.status == QuestionStatus.completed;

  @override
  void didUpdateWidget(covariant QuestionTimelineCard old) {
    super.didUpdateWidget(old);
    if (old.status != widget.status) _anim.value = 0;
  }

  Future<void> _handleDelete() async {
    if (_deleting) return;
    _deleting = true;

    final confirmed = await widget.onConfirmDelete?.call() ?? false;
    if (!confirmed || !mounted) {
      _deleting = false;
      return;
    }

    await _anim.forward();

    final ok = await (widget.onDelete?.call() ?? Future.value(false));
    if (!mounted) return;
    if (!ok) await _anim.reverse();

    _deleting = false;
  }

  Color _paperColor(double hour) {
    final cardBg = DaylightAppColors.cardBackground(hour);
    final accent = DaylightAppColors.accentGold(hour);
    final subtext = DaylightAppColors.cardSubtext(hour);

    switch (widget.status) {
      case QuestionStatus.completed:
        return cardBg;
      case QuestionStatus.current:
        return Color.lerp(cardBg, accent, 0.25)!;
      case QuestionStatus.locked:
        return Color.lerp(cardBg, subtext, 0.18)!;
    }
  }

  void _handleTapDown(TapDownDetails details) {
    final box = context.findRenderObject() as RenderBox?;
    final width = box?.size.width ?? 300;
    _tapWidthFactor = width > 0
        ? (details.localPosition.dx / width).clamp(0.0, 1.0)
        : 0.5;
    _press.forward();
  }

  void _releasePress() {
    _press.animateBack(
      0,
      duration: const Duration(milliseconds: 420),
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hour = DaylightTime.of(context);
    final paper = _paperColor(hour);

    final cardContent = AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final p = _anim.value;
        if (p >= 1.0) return const SizedBox.shrink();

        return GestureDetector(
          onTap: _deleting ? null : widget.onTap,
          onTapDown: _deleting ? null : _handleTapDown,
          onTapUp: _deleting ? null : (_) => _releasePress(),
          onTapCancel: _deleting ? null : _releasePress,
          behavior: HitTestBehavior.opaque,
          child: AnimatedBuilder(
            animation: _press,
            builder: (context, child) {
              final t = _press.value;
              final scaleX = 1.0 - (0.02 * t);
              final scaleY = 1.0 - (0.06 * t);
              final skew = 0.035 * t * (_tapWidthFactor - 0.5) * 2;
              final tiltX = 0.05 * t;

              return Transform(
                alignment: FractionalOffset(_tapWidthFactor, 0.5),
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0015)
                  ..rotateX(tiltX)
                  ..scale(scaleX, scaleY)
                  ..rotateZ(skew),
                child: child,
              );
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: (1 - p).clamp(0.0, 1.0),
                    child: CustomPaint(
                      painter: QuestionTimelineShadowPainter(),
                    ),
                  ),
                ),
                ClipPath(
                  clipper: DisintegratingCardClipper(progress: p, seed: _seed),
                  child: ClipPath(
                    clipper: QuestionTimelineClipper(),
                    child: CustomPaint(
                      foregroundPainter: QuestionTimelineBorderPainter(),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 92),
                        padding: const EdgeInsets.fromLTRB(20, 14, 12, 14),
                        color: paper,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: _QuestionContent(
                                question: widget.question,
                                status: widget.status,
                              ),
                            ),
                            const SizedBox(width: 12),
                            _DateColumn(date: widget.question.date),
                            if (isCompleted) ...[
                              const SizedBox(width: 5),
                              _ActionsButton(
                                onShare: widget.onShare,
                                onDelete: widget.onDelete == null
                                    ? null
                                    : _handleDelete,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (p > 0)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: EdgeDustPainter(progress: p, seed: _seed),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (!widget.enableFloatingDrag) return cardContent;

    return FloatingDragWrapper(child: cardContent);
  }
}

// ── QUESTION ─────────────────────────────────────────────────────────────────

class _QuestionContent extends StatelessWidget {
  const _QuestionContent({required this.question, required this.status});

  final ChapterQuestionModel question;
  final QuestionStatus status;

  @override
  Widget build(BuildContext context) {
    final hour = DaylightTime.of(context);
    final textColor = DaylightAppColors.cardText(hour);
    final subtext = DaylightAppColors.cardSubtext(hour);
    final accent = DaylightAppColors.accentGold(hour);
    final locked = status == QuestionStatus.locked;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (status == QuestionStatus.current)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              'CURRENT',
              style: GoogleFonts.cinzel(
                fontSize: 8.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: accent,
              ),
            ),
          ),
        Text(
          question.question,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.nunito(
            fontSize: 15,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w400,
            color: locked ? subtext.withOpacity(0.8) : textColor,
          ),
        ),
      ],
    );
  }
}

// ── DATE ──────────────────────────────────────────────────────────────────────

class _DateColumn extends StatelessWidget {
  const _DateColumn({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final hour = DaylightTime.of(context);
    final dateColor = DaylightAppColors.cardSubtext(hour);

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return SizedBox(
      width: 48,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${date.day} ${months[date.month - 1]}',
            textAlign: TextAlign.right,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: dateColor,
            ),
          ),
          Text(
            '${date.year}',
            textAlign: TextAlign.right,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 12,
              color: dateColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ── THREE DOT MENU ────────────────────────────────────────────────────────────

class _ActionsButton extends StatelessWidget {
  const _ActionsButton({required this.onShare, required this.onDelete});

  final VoidCallback? onShare;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final hour = DaylightTime.of(context);
    final menuBg = DaylightAppColors.cardBackground(hour);
    final textColor = DaylightAppColors.cardText(hour);

    return PopupMenuButton<_Action>(
      tooltip: 'Memory actions',
      padding: EdgeInsets.zero,
      offset: const Offset(-8, 36),
      color: menuBg,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (action) {
        switch (action) {
          case _Action.share:
            onShare?.call();
            break;
          case _Action.delete:
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (_) => [
        if (onShare != null)
          PopupMenuItem(
            value: _Action.share,
            child: Row(
              children: [
                Icon(Icons.mail_outline_rounded, size: 17, color: textColor),
                const SizedBox(width: 10),
                Text('Share memory', style: TextStyle(color: textColor)),
              ],
            ),
          ),
        if (onDelete != null)
          PopupMenuItem(
            value: _Action.delete,
            child: Row(
              children: [
                const Icon(
                  Icons.delete_outline_rounded,
                  size: 17,
                  color: Color(0xFF7A4438),
                ),
                const SizedBox(width: 10),
                Text('Delete memory', style: TextStyle(color: textColor)),
              ],
            ),
          ),
      ],
      child: SizedBox(
        width: 25,
        height: 34,
        child: Center(
          child: Icon(Icons.more_vert_rounded, size: 19, color: textColor),
        ),
      ),
    );
  }
}

enum _Action { share, delete }
