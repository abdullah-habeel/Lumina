import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lumina/core/routes/model/journel_entry_model.dart';
import 'package:lumina/features/auth/service/journal_service.dart';

class JournalController extends GetxController with WidgetsBindingObserver {
  final JournalService _service = JournalService();

  final RxList<JournalEntry> entries = <JournalEntry>[].obs;
  final RxBool isLoading = false.obs;
  StreamSubscription<List<JournalEntry>>? _entriesSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isDeleting = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _entriesSubscription = _service.streamEntries().listen(
      (list) {
        if (_isDeleting) return;
        entries.assignAll(list);
      },
      onError: (Object error) {
        debugPrint('JOURNAL_CONTROLLER: Could not load entries — $error');
      },
    );
    unawaited(_service.syncPendingEntries());
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (results) {
        if (results.any((result) => result != ConnectivityResult.none)) {
          unawaited(_service.syncPendingEntries());
        }
      },
      onError: (Object error) {
        debugPrint('JOURNAL_CONTROLLER: Connectivity listener failed — $error');
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_service.syncPendingEntries());
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _entriesSubscription?.cancel();
    _connectivitySubscription?.cancel();
    super.onClose();
  }

  bool isAnswered(String chapterId, String questionId) {
    return entries.any(
      (e) => e.chapterId == chapterId && e.questionId == questionId,
    );
  }

  JournalEntry? entryFor(String chapterId, String questionId) {
    for (final e in entries) {
      if (e.chapterId == chapterId && e.questionId == questionId) return e;
    }
    return null;
  }

  bool hasAnsweredToday(String chapterId) {
    final now = DateTime.now();
    return entries.any(
      (e) =>
          e.chapterId == chapterId &&
          e.date.year == now.year &&
          e.date.month == now.month &&
          e.date.day == now.day,
    );
  }

  bool hasAnsweredAnyBookQuestionToday() {
    final now = DateTime.now();
    return entries.any(
      (e) =>
          // ChaptersQuestionsData.bookOrder.contains(e.chapterId) &&
          e.date.year == now.year &&
          e.date.month == now.month &&
          e.date.day == now.day,
    );
  }

  Future<JournalEntry> addEntry(JournalEntry entry) async {
    isLoading.value = true;
    try {
      final saved = await _service.saveEntry(entry);
      final existingIndex = entries.indexWhere(
        (e) =>
            e.chapterId == saved.chapterId && e.questionId == saved.questionId,
      );
      if (existingIndex >= 0) {
        entries[existingIndex] = saved;
      } else {
        entries.add(saved);
      }
      return saved;
    } finally {
      isLoading.value = false;
    }
  }

    Future<void> deleteEntry(JournalEntry entry) async {
    _isDeleting = true;
    entries.removeWhere(
      (e) => e.chapterId == entry.chapterId && e.questionId == entry.questionId,
    );
    await _service.deleteEntry(entry);
    _isDeleting = false;
  }

  Future<void> refresh() async {
    _entriesSubscription?.cancel();
    _entriesSubscription = _service.streamEntries().listen(
      (list) {
        if (_isDeleting) return;
        entries.assignAll(list);
      },
      onError: (Object error) {
        debugPrint('JOURNAL_CONTROLLER: Could not load entries — $error');
      },
    );
  }

}
