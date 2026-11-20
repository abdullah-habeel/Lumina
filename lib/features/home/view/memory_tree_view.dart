import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import 'package:lumina/core/routes/constants/widgets/day_light_background.dart';
import 'package:lumina/core/routes/constants/widgets/day_light_colors.dart';
import 'package:lumina/core/routes/constants/widgets/time_aware_background.dart';
import 'package:lumina/features/delete_leaf/controller/delete_leaf_controller.dart';
import 'package:lumina/features/home/models/controller/home_controller.dart';
import 'package:lumina/features/home/widgets/sun_and_day_animation.dart';
import 'package:lumina/features/home/widgets/tree/growing_memory_tree.dart';
import 'package:lumina/features/home/widgets/tree/tree_leaf_anchor.dart';

class MemoryTreeView extends StatefulWidget {
  const MemoryTreeView({super.key});

  @override
  State<MemoryTreeView> createState() => _MemoryTreeViewState();
}

class _MemoryTreeViewState extends State<MemoryTreeView> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final size = MediaQuery.sizeOf(context);
    final hour = DayNight.currentHour();
    final headingColor = DaylightAppColors.headingText(hour);
    final subtextColor = DaylightAppColors.headingSubtext(hour);

    return TimeAwareBookBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          foregroundColor: headingColor,
          title: Text(
            'Your Tree',
            style: GoogleFonts.fraunces(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: headingColor,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
                child: Text(
                  'Each memory became a leaf.\nPinch to look closer.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: subtextColor),
                ),
              ),
              Expanded(
                child: Obx(() {
                  final count = controller.entries.length;
                  final deletedLeafController =
                      Get.find<DeletedLeafController>();
                  final deleted = deletedLeafController.deletedAnchorIndices;
                  final fallen = deletedLeafController.fallenAnchorIndices
                      .toSet();
                  final skipped = {...deleted, ...fallen};
                  final fallTrigger =
                      deletedLeafController.fallTriggerIndex.value;

                  final treeWidth = size.width * 1.55;
                  final treeHeight = size.height * 0.72;

                  return GestureDetector(
                    onTapUp: (details) {
                      final matrix = _transformationController.value;
                      final inverse = Matrix4.inverted(matrix);
                      final localPos = MatrixUtils.transformPoint(
                        inverse,
                        details.localPosition,
                      );

                      for (final anchorIndex in deleted) {
                        if (anchorIndex >= treeLeafAnchors.length) continue;
                        final anchor = treeLeafAnchors[anchorIndex];
                        final leafWidth = treeWidth * 0.042;
                        final leafHeight = leafWidth * 1.5;
                        final anchorX = anchor.x * treeWidth;
                        final anchorY = anchor.y * treeHeight;
                        final left = anchorX - leafWidth * 0.5;
                        final top = anchorY - leafHeight * 0.90;
                        final rect = Rect.fromLTWH(
                          left,
                          top,
                          leafWidth,
                          leafHeight,
                        ).inflate(10);

                        if (rect.contains(localPos)) {
                          deletedLeafController.triggerLeafFall(anchorIndex);
                          return;
                        }
                      }
                    },
                    child: InteractiveViewer(
                      transformationController: _transformationController,
                      constrained: false,
                      minScale: 0.65,
                      maxScale: 3.2,
                      boundaryMargin: const EdgeInsets.all(120),
                      child: Hero(
                        tag: 'memory_tree',
                        child: SizedBox(
                          width: treeWidth,
                          height: treeHeight,
                          child: GrowingMemoryTree(
                            entryCount: count,
                            maxLeaves: 96,
                            height: treeHeight,
                            enableLeafTap: true,
                            onLeafTap: controller.openMemoryFromLeaf,
                            deletedAnchorIndices: deleted,
                            skippedAnchorIndices: skipped,
                            fallTriggerIndex: fallTrigger,
                            onDeadLeafFallComplete: (anchorIndex) =>
                                deletedLeafController.onLeafFallComplete(
                                  anchorIndex,
                                ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              Obx(() {
                final count = controller.entries.length;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$count memories grown',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: headingColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Tap a leaf to read it',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: subtextColor),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
