import 'package:get/get.dart';
import 'package:lumina/core/routes/model/journel_entry_model.dart';
import 'package:lumina/features/auth/service/journal_service.dart';

class JournalController extends GetxController {
  final JournalService _service = JournalService();

  final RxList<JournalEntry> entries = <JournalEntry>[].obs;
  final RxBool isLoading = false.obs;
  bool _isDeleting = false;

  @override
  void onInit() {
    super.onInit();
    _service.streamEntries().listen((list) {
      if (_isDeleting) return;
      entries.assignAll(list);
    });
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
}
