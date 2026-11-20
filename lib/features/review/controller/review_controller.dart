import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewController extends GetxController {
  static const _entryCountKey = 'journal_entry_count';
  static const _hasAskedReviewKey = 'has_asked_review';
  static const _entryThreshold = 3;

  Future<void> onJournalEntrySaved() async {
    final prefs = await SharedPreferences.getInstance();

    final alreadyAsked = prefs.getBool(_hasAskedReviewKey) ?? false;
    if (alreadyAsked) return;

    final count = (prefs.getInt(_entryCountKey) ?? 0) + 1;
    await prefs.setInt(_entryCountKey, count);

    if (count >= _entryThreshold) {
      await _requestReview();
      await prefs.setBool(_hasAskedReviewKey, true);
    }
  }

  Future<void> _requestReview() async {
    final inAppReview = InAppReview.instance;

    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    }
  }
}