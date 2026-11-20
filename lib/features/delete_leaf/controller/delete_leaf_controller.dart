import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:lumina/core/controller/journal_controller.dart';
import 'package:lumina/features/delete_leaf/model/delete_leaf_model.dart';
import 'package:lumina/features/delete_leaf/service/deleted_leaf_service.dart';

class DeletedLeafController extends GetxController {
  final DeletedLeafService _service = DeletedLeafService();
  final JournalController _journalController = Get.find<JournalController>();

  final RxList<DeletedLeaf> deletedLeaves = <DeletedLeaf>[].obs;

  @override
  void onInit() {
    super.onInit();
    _service.streamDeletedLeaves().listen((list) {
      debugPrint('STREAM FIRED: ${list.map((l) => l.anchorIndex).toList()}');
      debugPrint('FALLEN: $fallenAnchorIndices');
      debugPrint(
        'DELETED: ${deletedLeaves.map((l) => l.anchorIndex).toList()}',
      );
      deletedLeaves.assignAll(
        list.where((l) => !fallenAnchorIndices.contains(l.anchorIndex)),
      );
      debugPrint(
        'AFTER ASSIGN: ${deletedLeaves.map((l) => l.anchorIndex).toList()}',
      );
    });
  }

  // Set of anchor indices that are yellow/dead leaves
  Set<int> get deletedAnchorIndices =>
      deletedLeaves.map((l) => l.anchorIndex).toSet();

  // Called when a memory is deleted — finds its anchor index and saves it
  Future<void> onMemoryDeleted(int anchorIndex) async {
    await _service.saveDeletedLeaf(anchorIndex);
  }

  // Called after fall animation completes — permanently removes yellow leaf
  // Anchor indices where leaf has already fallen — permanent empty gaps
  final RxSet<int> fallenAnchorIndices = <int>{}.obs;
  final RxInt fallTriggerIndex = (-1).obs;

  void triggerLeafFall(int anchorIndex) {
    fallTriggerIndex.value = anchorIndex;
  }

  // Called after fall animation completes — turns dead leaf into empty gap
  Future<void> onLeafFallComplete(int anchorIndex) async {
    // Add to fallen FIRST before removing from deleted
    // so skippedAnchorIndices never has a gap
    fallenAnchorIndices.add(anchorIndex);
    deletedLeaves.removeWhere((l) => l.anchorIndex == anchorIndex);
    await _service.removeDeletedLeaf(anchorIndex);
  }

  // All indices that should be skipped by live leaves
  Set<int> get allSkippedIndices =>
      deletedAnchorIndices.union(fallenAnchorIndices);

  // Returns the anchor index for a given entry before deletion
  int getAnchorIndexForEntry(int entryIndexInSortedList) {
    final skipped = allSkippedIndices.toList()..sort();

    int anchor = entryIndexInSortedList;
    for (final d in skipped) {
      if (d <= anchor) anchor++;
    }
    return anchor;
  }
}
