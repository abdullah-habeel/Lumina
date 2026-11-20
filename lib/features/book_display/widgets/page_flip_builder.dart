// import 'package:flutter/material.dart';

// /// A lightweight, dependency-free page-flip widget.
// /// Drag left/right to flip between pages. No internal GlobalKey tricks —
// /// just an AnimationController driving a 3D Transform.
// class PageFlipBuilder extends StatefulWidget {
//   final List<Widget> children;
//   final Widget? lastPage;

//   const PageFlipBuilder({
//     super.key,
//     required this.children,
//     this.lastPage,
//   });

//   @override
//   State<PageFlipBuilder> createState() => PageFlipBuilderState();
// }

// class PageFlipBuilderState extends State<PageFlipBuilder>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;
//   int _currentIndex = 0;
//   int? _nextIndex;
//   bool _forward = true;

//   int get _pageCount =>
//       widget.children.length + (widget.lastPage != null ? 1 : 0);

//   Widget _pageAt(int index) {
//     if (index >= widget.children.length) {
//       return widget.lastPage ?? const SizedBox.shrink();
//     }
//     return widget.children[index];
//   }

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     )..addStatusListener((status) {
//         if (status == AnimationStatus.completed) {
//           setState(() {
//             _currentIndex = _nextIndex ?? _currentIndex;
//             _nextIndex = null;
//             _controller.value = 0;
//           });
//         }
//       });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   void nextPage() {
//     if (_currentIndex < _pageCount - 1 && _controller.isAnimating == false) {
//       _forward = true;
//       _nextIndex = _currentIndex + 1;
//       _controller.forward(from: 0);
//     }
//   }

//   void previousPage() {
//     if (_currentIndex > 0 && _controller.isAnimating == false) {
//       _forward = false;
//       _nextIndex = _currentIndex - 1;
//       _controller.forward(from: 0);
//     }
//   }

//   void goToPage(int index) {
//     if (index == _currentIndex || index < 0 || index >= _pageCount) return;
//     _forward = index > _currentIndex;
//     _nextIndex = index;
//     _controller.forward(from: 0);
//   }

//   void _onDragEnd(DragEndDetails details) {
//     final velocity = details.primaryVelocity ?? 0;
//     if (velocity < -200) {
//       nextPage();
//     } else if (velocity > 200) {
//       previousPage();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onHorizontalDragEnd: _onDragEnd,
//       child: Stack(
//         children: [
//           // Static current page underneath.
//           _pageAt(_currentIndex),

//           // Animated flipping page on top, only while animating.
//           if (_nextIndex != null)
//             AnimatedBuilder(
//               animation: _controller,
//               builder: (context, child) {
//                 final t = _controller.value;
//                 final angle = _forward ? t * 3.14159 : -t * 3.14159;
//                 final showingFront = _forward ? t < 0.5 : t > 0.5;

//                 final matrix = Matrix4.identity()
//                   ..setEntry(3, 2, 0.0015)
//                   ..rotateY(angle);

//                 return Transform(
//                   alignment: Alignment.centerLeft,
//                   transform: matrix,
//                   child: showingFront
//                       ? _pageAt(_currentIndex)
//                       : Transform(
//                           alignment: Alignment.center,
//                           transform: Matrix4.identity()..rotateY(3.14159),
//                           child: _pageAt(_nextIndex!),
//                         ),
//                 );
//               },
//             ),
//         ],
//       ),
//     );
//   }
// }
