import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/music_controller.dart';

/// Wrap the Scaffold of any screen that should play background music.
/// Music starts when the screen mounts and pauses (unless another
/// wrapped screen is also on the stack) when it unmounts.
class MusicScreenWrapper extends StatefulWidget {
  final Widget child;

  const MusicScreenWrapper({super.key, required this.child});

  @override
  State<MusicScreenWrapper> createState() => _MusicScreenWrapperState();
}

class _MusicScreenWrapperState extends State<MusicScreenWrapper> {
  @override
  void initState() {
    super.initState();
    Get.find<MusicController>().enterMusicScreen();
  }

  @override
  void dispose() {
    Get.find<MusicController>().exitMusicScreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}