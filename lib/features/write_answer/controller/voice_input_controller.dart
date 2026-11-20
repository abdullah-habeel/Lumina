
import 'dart:async';

import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceInputController extends GetxController {
  final SpeechToText _speech = SpeechToText();

  final isListening = false.obs;
  final isAvailable = false.obs;

  // Contains ALL speech recognized during the current recording.
  final transcribedText = ''.obs;

  // Kept for compatibility with your existing screen.
  final sessionRestarted = 0.obs;

  bool _userWantsListening = false;
  bool _restartInProgress = false;

  Timer? _restartTimer;

  String _committedSpeech = '';
  String _currentSessionText = '';

  @override
  void onInit() {
    super.onInit();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      final available = await _speech.initialize(
        onError: (error) {
          if (_userWantsListening) {
            _scheduleRestart();
          } else {
            isListening(false);
          }
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (_userWantsListening) {
              _scheduleRestart();
            } else {
              isListening(false);
            }
          }
        },
      );

      isAvailable(available);
    } catch (_) {
      isAvailable(false);
    }
  }

  void _scheduleRestart() {
    if (!_userWantsListening ||
        _restartInProgress ||
        (_restartTimer?.isActive ?? false)) {
      return;
    }

    _restartTimer = Timer(
      const Duration(milliseconds: 500),
      () async {
        // Give the speech plugin time to deliver its final result.
        await Future.delayed(const Duration(milliseconds: 300));

        if (!_userWantsListening) return;

        // Commit this session exactly once.
        if (_currentSessionText.isNotEmpty) {
          final previous = _committedSpeech.trimRight();
          final current = _currentSessionText.trim();

          _committedSpeech = previous.isEmpty
              ? current
              : current.isEmpty
                  ? previous
                  : '$previous $current';

          _currentSessionText = '';
          _publishTranscript();
        }

        await _restartSession();
      },
    );
  }

  void _publishTranscript() {
  transcribedText.value = _committedSpeech.isEmpty
      ? _currentSessionText
      : _currentSessionText.isEmpty
          ? _committedSpeech
          : '$_committedSpeech $_currentSessionText';
}

  Future<void> _restartSession() async {
    if (!isAvailable.value ||
        !_userWantsListening ||
        _restartInProgress) {
      return;
    }

    _restartInProgress = true;

    try {
      sessionRestarted.value++;

      await _speech.listen(
        onResult: (result) {
          if (!_userWantsListening) return;

          // Replace the temporary session transcript, never the
          // previously committed speech.
          _currentSessionText = result.recognizedWords;

          _publishTranscript();
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 15),
        partialResults: true,
        cancelOnError: false,
      );
    } catch (_) {
      // Keep already recognized text if listening fails.
    } finally {
      _restartInProgress = false;
    }
  }

  Future<void> startListening() async {
    if (!isAvailable.value || _userWantsListening) return;

    _restartTimer?.cancel();

    _committedSpeech = '';
    _currentSessionText = '';
    transcribedText('');

    _userWantsListening = true;
    isListening(true);

    await _restartSession();
  }

  Future<void> stopListening() async {
    if (!_userWantsListening) return;

    // Prevent status callbacks from starting another session.
    _userWantsListening = false;
    _restartTimer?.cancel();

    try {
      await _speech.stop();

      // Include the last session's transcript without clearing
      // the words recognized in earlier sessions.
      if (_currentSessionText.isNotEmpty) {
  final previous = _committedSpeech.trimRight();
  final current = _currentSessionText.trim();

  _committedSpeech = previous.isEmpty
      ? current
      : current.isEmpty
          ? previous
          : '$previous $current';

  _currentSessionText = '';
  // do NOT publish here — avoids the brief flash of shorter text
}

await _restartSession();
    } finally {
      isListening(false);
    }
  }

  void toggleListening() {
    if (_userWantsListening) {
      stopListening();
    } else {
      startListening();
    }
  }

  @override
  void onClose() {
    _userWantsListening = false;
    _restartTimer?.cancel();
    _speech.stop();
    super.onClose();
  }
}
