import 'package:flutter/material.dart';
import 'package:lumina/core/routes/constants/app_images.dart';

/// Decorative row: branch — text — branch.
///
/// We only ship ONE branch asset (`assets/images/branch.png`). The right
/// side is the exact same image, mirrored horizontally with [Transform.flip],
/// so we never need a second "mirrored" asset in the project.
class BranchDivider extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final double branchWidth;
  final double branchHeight;

  const BranchDivider({
    super.key,
    required this.text,
    this.textStyle,
    this.branchWidth = 70,
    this.branchHeight = 70,
  });

  @override
  Widget build(BuildContext context) {
    final branch = Image.asset(
      AppImages.leafone,
      width: branchWidth,
      height: branchHeight,
      fit: BoxFit.contain,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        branch,
        const SizedBox(width: 1),
        Text(text, style: textStyle),
        // const SizedBox(width: 10),
        Transform.flip(flipX: true, child: branch),
      ],
    );
  }
}
