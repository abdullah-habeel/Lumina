import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lumina/features/shared/model/shared_model.dart';
import 'package:lumina/features/shared/widgets/share_card/shared_card_paint.dart';
import 'package:lumina/features/shared/widgets/share_card/shared_letter_face.dart';

class SharedPageCard extends StatefulWidget {
  final SharedPage page;
  final VoidCallback? onTap;
  final Future<SharedDeleteScope?> Function(SharedPage)? onChooseDeleteScope;
  final Future<bool> Function(SharedPage, SharedDeleteScope)? onDelete;

  const SharedPageCard({
    super.key,
    required this.page,
    this.onTap,
    this.onChooseDeleteScope,
    this.onDelete,
  });

  @override
  State<SharedPageCard> createState() => _SharedPageCardState();
}

class _SharedPageCardState extends State<SharedPageCard>
    with TickerProviderStateMixin {
  late final AnimationController _deleteController;
  late final AnimationController _pressController;
  late final AnimationController _breathController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _liftAnim;

  Offset _tilt = Offset.zero;
  double _tapWidthFactor = 0.5; // 0 = left edge, 1 = right edge of the card
  bool _deleting = false;

  static const _months = [
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

  @override
  void initState() {
    super.initState();

    _deleteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
    );

    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 1.015,
    ).animate(CurvedAnimation(parent: _pressController, curve: Curves.easeOut));

    _liftAnim = Tween<double>(
      begin: 0.0,
      end: -5.0,
    ).animate(CurvedAnimation(parent: _pressController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _deleteController.dispose();
    _pressController.dispose();
    _breathController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (_deleting) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      final local = box.globalToLocal(details.globalPosition);
      _tapWidthFactor = (local.dx / box.size.width).clamp(0.0, 1.0);
      _tilt = Offset(
        ((local.dx / box.size.width) - 0.5) * 0.12,
        ((local.dy / box.size.height) - 0.5) * -0.08,
      );
    }
    _pressController.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails _) {
    _pressController.reverse();
    _tilt = Offset.zero;
  }

  void _onTapCancel() {
    _pressController.reverse();
    _tilt = Offset.zero;
  }

  void _handleTap() {
    if (_deleting) return;
    widget.onTap?.call();
  }

  void _handleLongPress() {
    if (_deleting) return;
    HapticFeedback.mediumImpact();
    _handleDelete();
  }

  Future<void> _handleDelete() async {
    if (_deleting) return;

    final deleteScope = widget.onChooseDeleteScope == null
        ? SharedDeleteScope.forMe
        : await widget.onChooseDeleteScope!.call(widget.page);
    if (deleteScope == null) return;
    if (!mounted) return;

    setState(() => _deleting = true);

    await _deleteController.forward(from: 0);
    if (!mounted) return;

    final deleted =
        await widget.onDelete?.call(widget.page, deleteScope) ?? true;

    if (!deleted && mounted) {
      setState(() => _deleting = false);
      _deleteController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isReceived = widget.page.direction == SharedDirection.received;
    final displayDate = widget.page.sharedAt ?? widget.page.date;
    final dateText =
        '${_months[displayDate.month - 1]} ${displayDate.day}, ${displayDate.year}';
    final rotation = isReceived ? -0.005 : 0.004;
    final seed = isReceived ? 1.0 : 2.0;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _deleteController,
        _pressController,
        _breathController,
      ]),
      builder: (context, _) {
        final deleteProgress = _deleteController.value;
        final float = _deleting ? 0.0 : (_breathController.value - 0.5) * 4.0;

        return GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: _handleTap,
          onLongPress: _handleLongPress,
          child: Transform.translate(
            offset: Offset(0, _liftAnim.value + float),
            child: Transform(
              alignment: FractionalOffset(_tapWidthFactor, 0.5),
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0014)
                ..rotateX(_tilt.dy)
                ..rotateY(-_tilt.dx)
                ..scale(
                  _scaleAnim.value - (_pressController.value * 0.01),
                  _scaleAnim.value + (_pressController.value * 0.015),
                )
                ..rotateZ(
                  _pressController.value * 0.02 * (_tapWidthFactor - 0.5) * 2,
                ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: PaperShadowPainter(
                          seed: seed,
                          elevation: _pressController.value,
                        ),
                      ),
                    ),
                  ),
                  Transform.rotate(
                    angle: rotation,
                    child: ClipPath(
                      clipper: DisintegratingCardClipper(
                        progress: deleteProgress,
                        seed: seed,
                      ),
                      child: Opacity(
                        opacity: (1.0 - deleteProgress * 0.12).clamp(0.0, 1.0),
                        child: SharedLetterFace(
                          seed: seed,
                          press: _pressController.value,
                          breath: _breathController.value,
                          isReceived: isReceived,
                          personName: widget.page.personName,
                          question: widget.page.question,
                          dateText: dateText,
                          isNew: widget.page.isNew,
                          isSeen: widget.page.isSeen,
                          onTap: _handleTap,
                          onLongPress: _handleLongPress,
                        ),
                      ),
                    ),
                  ),
                  if (_deleting)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: EdgeDustPainter(
                            progress: deleteProgress,
                            seed: seed,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
