import 'package:get/get.dart';
import 'package:lumina/core/controller/journal_controller.dart';
import 'package:lumina/core/routes/model/journel_entry_model.dart';

class AiLogEntry {
  final String operation;
  final String inferenceSource;
  final DateTime date;
  final String memoryQuestion;

  AiLogEntry({
    required this.operation,
    required this.inferenceSource,
    required this.date,
    required this.memoryQuestion,
  });
}

class AiLogController extends GetxController {
  final JournalController _journalController = Get.find<JournalController>();

  final RxList<AiLogEntry> logEntries = <AiLogEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    _buildLog();

    // Rebuild log whenever entries change
    ever(_journalController.entries, (_) => _buildLog());
  }

  void _buildLog() {
    final entries = _journalController.entries;
    final log = <AiLogEntry>[];

    for (final entry in entries) {
      final status = entry.taggingStatus;
      if (status == null) continue;

      log.add(
        AiLogEntry(
          operation: 'Memory tagged',
          inferenceSource: entry.inferenceSource ?? 'unknown',
          date: entry.date,
          memoryQuestion: entry.question,
        ),
      );
    }

    // Sort newest first
    log.sort((a, b) => b.date.compareTo(a.date));
    logEntries.assignAll(log);
  }

  String labelFor(String source) {
  final normalized = source.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_');
  switch (normalized) {
    case 'on_device':
      return 'On-Device';
    case 'in_cloud':
      return 'In Cloud';
    case 'failed':
      return 'Failed';
    default:
      return 'Unknown';
  }
}
}