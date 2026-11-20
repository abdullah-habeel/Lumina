import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina/core/controller/journal_controller.dart';
import 'package:lumina/core/routes/app_routes.dart';
import 'package:lumina/core/routes/constants/app_colors.dart';
import 'package:lumina/core/routes/constants/app_images.dart';
import 'package:lumina/core/routes/model/journel_entry_model.dart';
import 'package:lumina/features/auth/service/username_service.dart';
import 'package:lumina/features/delete_leaf/controller/delete_leaf_controller.dart';
import 'package:lumina/features/home/models/chapter_models.dart';
import 'package:lumina/features/home/widgets/tree/growing_memory_tree.dart';
import 'package:lumina/features/home/widgets/tree/leaf_fly_animator.dart';
import 'package:lumina/features/home/widgets/tree/tree_leaf_anchor.dart';
import 'package:lumina/features/music/controller/sound_effects_controller.dart';
import 'package:lumina/features/review/controller/review_controller.dart';

class HomeController extends GetxController {
  final JournalController _journalController = Get.find<JournalController>();

  final RxString userName = 'there'.obs;
  final RxString profilePhotoUrl = ''.obs;

  // ============================================================
  // TREE KEY
  // ============================================================

  /// This key MUST be attached directly to GrowingMemoryTree.
  final GlobalKey treeKey = GlobalKey();

  // ============================================================
  // CHAPTERS
  // ============================================================

  final RxList<ChapterModel> chapters = <ChapterModel>[
    ChapterModel(
      chapterId: 'beginnings',
      number: 1,
      title: 'Beginnings',
      subtitle: 'Where it all begins',
      thumbnailImage: AppImages.chapterBeginnings,
      backgroundImage: AppImages.questiontree,
      // bgColor: const Color(0xffddd2b2),
      bgColor: const Color(0xffC8A97E),
    ),
    ChapterModel(
      chapterId: 'becoming_me',
      number: 2,
      title: 'Becoming Me',
      subtitle: 'The journey that shaped me.',
      thumbnailImage: AppImages.questionflower,
      backgroundImage: AppImages.lighthousetower,
      bgColor: const Color(0xffA0845C),
    ),
    ChapterModel(
      chapterId: 'right_now',
      number: 3,
      title: 'Right Now',
      subtitle: 'The person I am today',
      thumbnailImage: AppImages.chapterGrowingYears,
      backgroundImage: AppImages.mountains,
      bgColor: Color(0xff6B4F35),
    ),
  ].obs;

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    loadUserName();
    _loadProfilePhoto();
  }

  @override
  void onReady() {
    super.onReady();

    _checkUsernameSetup();

    // IMPORTANT:
    //
    // DO NOT start the leaf animation here.
    //
    // HomeView waits until the tree has actually been laid out
    // and then calls playPendingLeafAnimation().
  }

  // ============================================================
  // PLAY PENDING LEAF ANIMATION
  // ============================================================

  Future<void> playPendingLeafAnimation(
    BuildContext context,
    dynamic pendingEntry,
  ) async {
    // ------------------------------------------------------------
    // Validate entry.
    // ------------------------------------------------------------

    if (pendingEntry is! JournalEntry) {
      debugPrint('HOME CONTROLLER: pendingEntry is not JournalEntry.');
      return;
    }

    final JournalEntry entry = pendingEntry;

    // ------------------------------------------------------------
    // Make sure tree exists.
    // ------------------------------------------------------------

    final BuildContext? treeContext = treeKey.currentContext;

    if (treeContext == null) {
      debugPrint('HOME CONTROLLER: tree context is null.');

      // Safety fallback.
      await _journalController.addEntry(entry);
      return;
    }

    final RenderObject? renderObject = treeContext.findRenderObject();

    if (renderObject is! RenderBox || !renderObject.hasSize) {
      debugPrint('HOME CONTROLLER: tree RenderBox is not ready.');

      // Safety fallback.
      await _journalController.addEntry(entry);
      return;
    }

    // ------------------------------------------------------------
    // GET TREE GLOBAL RECT.
    // ------------------------------------------------------------

    final RenderBox renderBox = renderObject;

    final Offset treeTopLeft = renderBox.localToGlobal(Offset.zero);

    final Rect treeRect = _actualTreeRect(
      topLeft: treeTopLeft,
      size: renderBox.size,
    );

    debugPrint('HOME CONTROLLER: Tree rect = $treeRect');

    // ------------------------------------------------------------
    // CURRENT NUMBER OF LEAVES.
    //
    // IMPORTANT:
    //
    // Do this BEFORE adding the entry.
    //
    // 0 entries -> leaf index 0
    // 1 entry   -> leaf index 1
    // 2 entries -> leaf index 2
    // ------------------------------------------------------------

    // Calculate the correct anchor index accounting for skipped positions.
    final deletedLeafController = Get.find<DeletedLeafController>();
    final skipped = deletedLeafController.allSkippedIndices;

    int liveCount = _journalController.entries.length;
    int anchorIndex = 0;

    while (anchorIndex < treeLeafAnchors.length) {
      if (skipped.contains(anchorIndex)) {
        anchorIndex++;
        continue;
      }

      if (liveCount == 0) break;
      liveCount--;
      anchorIndex++;
    }

    final nextLeafIndex = anchorIndex;
    if (nextLeafIndex >= treeLeafAnchors.length) {
      await _journalController.addEntry(entry);
      return;
    }

    debugPrint(
      'HOME CONTROLLER: '
      'Starting flying leaf animation. '
      'nextLeafIndex = $nextLeafIndex',
    );

    // ------------------------------------------------------------
    // START FLYING LEAF.
    // ------------------------------------------------------------

    LeafFlyAnimator.fly(
      context: context,
      nextLeafIndex: nextLeafIndex,
      treeRect: treeRect,

      // ----------------------------------------------------------
      // THIS RUNS AFTER THE LEAF REACHES THE TREE.
      // ----------------------------------------------------------
      onComplete: () async {
        debugPrint(
          'HOME CONTROLLER: '
          'Leaf reached tree. Saving entry now.',
        );

        await _journalController.addEntry(entry);
        if (Get.isRegistered<ReviewController>()) {
          Get.find<ReviewController>().onJournalEntrySaved();
        }

        debugPrint(
          'HOME CONTROLLER: '
          'Entry saved. Tree should now show new leaf.',
        );
      },
    );
  }

  Rect _actualTreeRect({required Offset topLeft, required Size size}) {
    const double homeTreeHeight = 240;
    final double treeHeight = size.height < homeTreeHeight
        ? size.height
        : homeTreeHeight;
    final double treeWidth = math.min(
      size.width,
      treeHeight * GrowingMemoryTree.treeAspectRatio,
    );

    return Rect.fromLTWH(
      topLeft.dx + ((size.width - treeWidth) / 2),
      topLeft.dy + ((size.height - treeHeight) / 2),
      treeWidth,
      treeHeight,
    );
  }

  // ============================================================
  // USER
  // ============================================================

  void loadUserName() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      userName.value = 'there';
      return;
    }

    final displayName = user.displayName?.trim();

    if (displayName != null && displayName.isNotEmpty) {
      userName.value = displayName.split(' ').first;
    } else if (user.email != null && user.email!.isNotEmpty) {
      userName.value = user.email!.split('@').first;
    } else {
      userName.value = 'there';
    }
  }

  Future<void> _loadProfilePhoto() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    profilePhotoUrl.value = user.photoURL ?? '';

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final fetchedPhotoUrl = (doc.data()?['photoUrl'] as String?)?.trim();

      if (fetchedPhotoUrl != null && fetchedPhotoUrl.isNotEmpty) {
        profilePhotoUrl.value = fetchedPhotoUrl;
      }
    } catch (e) {
      debugPrint('HOME: profile photo fetch failed: $e');
    }
  }

  Future<void> _checkUsernameSetup() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      final usernameService = UsernameService();

      final needsSetup = await usernameService
          .needsUsernameSetup(user.uid)
          .timeout(const Duration(seconds: 8));

      if (needsSetup) {
        Get.toNamed(AppRoutes.usernameSetup);
      }
    } catch (e) {
      debugPrint('HOME: username check failed: $e');
    }
  }

  // ============================================================
  // JOURNAL / CHAPTER
  // ============================================================

  

  RxList<JournalEntry> get entries => _journalController.entries;

  int get memoryLeafCount => _journalController.entries.length;

  int answeredFor(String chapterId) =>
      _journalController.entries.where((e) => e.chapterId == chapterId).length;

  

  void onStartWriting() {
    if (_journalController.hasAnsweredAnyBookQuestionToday()) {
      Get.snackbar(
        'One question a day',
        'Please come back tomorrow for the next question.',
      );

      return;
    }

    Get.toNamed(AppRoutes.todayquestion);
  }

  void onViewAllChapters() {}

  // ============================================================
  // CHAPTER TAP
  // ============================================================

  

  List<JournalEntry> get treeMemories =>
      List<JournalEntry>.from(_journalController.entries);

  void openMemoryTree() {
    if (memoryLeafCount == 0) {
      Get.snackbar(
        'Your tree is still young',
        'Save a memory and a new leaf will grow.',
      );
      return;
    }

    Get.toNamed(AppRoutes.memoryTree);
  }

  void openMemoryFromLeaf(int leafIndex) {
    final memories = treeMemories;
    if (leafIndex < 0 || leafIndex >= memories.length) return;
    Get.toNamed(AppRoutes.memoryDetail, arguments: memories[leafIndex]);
  }
}
