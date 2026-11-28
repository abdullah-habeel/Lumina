import 'dart:async';
import 'package:get/get.dart';
import 'package:lumina/core/service/hybrid_ai_service.dart';

class OnDeviceDownloadService extends GetxService {
  final HybridAiService _hybridAi = HybridAiService();

  final RxString status = ''.obs;
  final RxInt percent = 0.obs;
  final RxBool isDone = false.obs;

  StreamSubscription? _sub;

  Future<void> init() async {
    try {
      final result = await _hybridAi.checkOnDeviceAvailability();
      final raw = result['status']?.toString().toUpperCase() ?? 'UNKNOWN';

      if (raw.contains('AVAILABLE') && !raw.contains('UNAVAILABLE')) {
        status.value = 'AVAILABLE';
        isDone.value = true;
        return;
      }

      if (raw.contains('DOWNLOADABLE')) {
        status.value = 'DOWNLOADING';
        percent.value = 0;

        _sub = _hybridAi.downloadProgressStream.listen((event) {
          final p = event['percent'] as int? ?? 0;
          percent.value = p;
          if (event['done'] == true || p >= 100) {
            status.value = 'AVAILABLE';
            isDone.value = true;
            _sub?.cancel();
          }
        }, onError: (_) {
          status.value = 'ERROR';
        });

        _hybridAi.startDownload();
        return;
      }

      status.value = 'UNSUPPORTED';
    } catch (_) {
      status.value = 'UNSUPPORTED';
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}