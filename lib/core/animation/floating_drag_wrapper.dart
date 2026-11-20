import 'dart:async';
import 'package:flutter/material.dart';

class FloatingDragWrapper extends StatefulWidget {
  const FloatingDragWrapper({
    super.key,
    required this.child,
    this.enabled = true,
  });

  final Widget child;
  final bool enabled;
 
  @override
  State<FloatingDragWrapper> createState() => _FloatingDragWrapperState();
}

class _FloatingDragWrapperState extends State<FloatingDragWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
    reverseDuration: const Duration(milliseconds: 260),
  );

  OverlayEntry? _dragOverlay;
  Timer? _overlayCleanupTimer;

  Offset _dragOrigin = Offset.zero;
  Offset _dragPosition = Offset.zero;
  Offset _fingerOffset = Offset.zero;

  double _dragRotation = 0;
  double _dragWidth = 0;

  bool _isDragging = false;
  bool _isReturning = false;

  bool get _active => _isDragging || _isReturning;

  void _releasePress() {
    _press.animateBack(
      0,
      duration: const Duration(milliseconds: 420),
      curve: Curves.elasticOut,
    );
  }

  void _startFloatingDrag(LongPressStartDetails details) {
    if (!widget.enabled || _isDragging) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final overlay = Overlay.of(context);
    final overlayBox = overlay.context.findRenderObject() as RenderBox?;
    if (overlayBox == null) return;

    final cardTopLeft = overlayBox.globalToLocal(
      renderBox.localToGlobal(Offset.zero),
    );
    final fingerPosition = overlayBox.globalToLocal(details.globalPosition);

    _dragOrigin = cardTopLeft;
    _dragPosition = cardTopLeft;
    _fingerOffset = fingerPosition - cardTopLeft;
    _dragWidth = renderBox.size.width;
    _dragRotation = 0;
    _isDragging = true;
    _isReturning = false;

    _press.forward();

    _dragOverlay = OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedPositioned(
              duration: _isReturning
                  ? const Duration(milliseconds: 420)
                  : Duration.zero,
              curve: Curves.easeOutBack,
              left: _isReturning ? _dragOrigin.dx : _dragPosition.dx,
              top: _isReturning ? _dragOrigin.dy : _dragPosition.dy,
              onEnd: () {
                if (_isReturning) _removeDragOverlay();
              },
              child: IgnorePointer(
                child: Material(
                  color: Colors.transparent,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateZ(_isReturning ? 0 : _dragRotation)
                      ..scale(_isReturning ? 1.0 : 1.035),
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.24),
                            blurRadius: _isReturning ? 5 : 22,
                            offset: Offset(0, _isReturning ? 2 : 14),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: _dragWidth,
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_dragOverlay!);
    setState(() {});
  }

  void _updateFloatingDrag(LongPressMoveUpdateDetails details) {
    if (!_isDragging || _dragOverlay == null) return;

    final overlay = Overlay.of(context);
    final overlayBox = overlay.context.findRenderObject() as RenderBox?;
    if (overlayBox == null) return;

    final fingerPosition = overlayBox.globalToLocal(details.globalPosition);
    _dragPosition = fingerPosition - _fingerOffset;
    _dragRotation =
        (details.offsetFromOrigin.dx * 0.0008).clamp(-0.08, 0.08);

    _dragOverlay?.markNeedsBuild();
  }

  void _endFloatingDrag(LongPressEndDetails details) {
    if (!_isDragging || _dragOverlay == null) return;

    _isDragging = false;
    _isReturning = true;
    _dragPosition = _dragOrigin;
    _dragRotation = 0;

    _releasePress();
    _dragOverlay?.markNeedsBuild();

    _overlayCleanupTimer?.cancel();
    _overlayCleanupTimer = Timer(
      const Duration(milliseconds: 500),
      _removeDragOverlay,
    );
  }

  void _removeDragOverlay() {
    _overlayCleanupTimer?.cancel();
    _overlayCleanupTimer = null;

    final overlay = _dragOverlay;
    _dragOverlay = null;

    overlay?.remove();
    overlay?.dispose();

    _isDragging = false;
    _isReturning = false;

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _overlayCleanupTimer?.cancel();
    _dragOverlay?.remove();
    _dragOverlay?.dispose();
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: widget.enabled ? _startFloatingDrag : null,
      onLongPressMoveUpdate: widget.enabled ? _updateFloatingDrag : null,
      onLongPressEnd: widget.enabled ? _endFloatingDrag : null,
      onLongPressCancel: () {
        if (_active) {
          _removeDragOverlay();
          _releasePress();
        }
      },
      child: Opacity(
        opacity: _active ? 0 : 1,
        child: widget.child,
      ),
    );
  }
}