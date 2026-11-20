import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lumina/features/music/controller/music_controller.dart';

class SoundEffectsController extends GetxService {
  final AudioPlayer _pageFlipPlayer = AudioPlayer(playerId: 'page_flip_sfx');

  final AudioPlayer _bookOpeningPlayer = AudioPlayer(
    playerId: 'book_opening_sfx',
  );

  final AudioPlayer _leafAppearPlayer = AudioPlayer(
    playerId: 'leaf_appear_sfx',
  );
  final AudioPlayer _pencilWritingPlayer = AudioPlayer(
    playerId: 'pencil_writing_sfx',
  );

  // ---------------- STORM (rain + thunder) ----------------
  final AudioPlayer _rainPlayer = AudioPlayer(playerId: 'rain_sfx');
  final AudioPlayer _thunderPlayer = AudioPlayer(playerId: 'thunder_sfx');

  static const String _rainAsset = 'music/rain_gentle.mp3';
  static const String _thunderAsset = 'music/lightning_two.mp3';

  // If a file has silence at its start, skip it here.
  static const Duration _rainStartAt = Duration.zero;
  static const Duration _thunderStartAt = Duration.zero;

  final List<Timer> _stormTimers = [];
  int _rainToken = 0;
  int _thunderToken = 0;

  late Future<void> _playersReady;
  final RxBool isSoundEffectsEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();

    final effectAudioContext = AudioContextConfig(
      focus: AudioContextConfigFocus.mixWithOthers,
    ).build();

    _playersReady = Future.wait([
      _configurePlayer(_pageFlipPlayer, effectAudioContext),
      _configurePlayer(_bookOpeningPlayer, effectAudioContext),
      _configurePlayer(_leafAppearPlayer, effectAudioContext),
      _configurePlayer(_pencilWritingPlayer, effectAudioContext),
      _configurePlayer(_rainPlayer, effectAudioContext),
      _configurePlayer(_thunderPlayer, effectAudioContext),
    ]);
    loadPreference();
  }

  Future<void> loadPreference() async {
    try {
      if (Firebase.apps.isEmpty) return;
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final savedEnabled = doc.data()?['isSoundEffectsEnabled'] as bool?;
      if (savedEnabled != null) {
        isSoundEffectsEnabled.value = savedEnabled;
      }
    } catch (_) {
      // Keep the default when the preference cannot be loaded.
    }
  }

  Future<void> toggleSoundEffects(bool enabled) async {
    isSoundEffectsEnabled.value = enabled;
    try {
      if (Firebase.apps.isEmpty) return;
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'isSoundEffectsEnabled': enabled,
      }, SetOptions(merge: true));
    } catch (_) {
      // Non-critical — keep the local setting.
    }
  }

  Future<void> _configurePlayer(
    AudioPlayer player,
    AudioContext audioContext,
  ) async {
    await player.setPlayerMode(PlayerMode.mediaPlayer);
    await player.setReleaseMode(ReleaseMode.stop);
    await player.setAudioContext(audioContext);
  }

  Future<void> playPageFlip() async {
    if (!isSoundEffectsEnabled.value) return;
    try {
      await _pageFlipPlayer.stop();

      await _pageFlipPlayer.play(
        AssetSource('music/book_opening.mp3'),
        volume: 1,
      );

      _resumeBackgroundMusicSoon();
    } catch (_) {
      // Non-critical.
    }
  }

  Future<void> playBookOpening() async {
    if (!isSoundEffectsEnabled.value) return;
    try {
      await _bookOpeningPlayer.stop();

      await _bookOpeningPlayer.play(
        AssetSource('music/buterfly.mp3'),
        volume: 1,
      );

      _resumeBackgroundMusicSoon();
    } catch (_) {
      // Non-critical.
    }
  }

  // ============================================================
  // LEAF APPEAR SOUND
  // ============================================================

  Future<void> playLeafAppear() async {
    if (!isSoundEffectsEnabled.value) return;
    debugPrint('SoundEffectsController: playing leaf sound');
    try {
      await _playersReady;
      await _leafAppearPlayer.stop();

      await _leafAppearPlayer.play(
        AssetSource('music/leaf_sound.mp3'),
        volume: 1,
      );

      _resumeBackgroundMusicSoon();
    } catch (error) {
      debugPrint('SoundEffectsController: leaf sound failed: $error');
    }
  }

  // ============================================================
  // PENCIL WRITING SOUND
  // ============================================================

  Future<void> startPencilWriting() async {
    if (!isSoundEffectsEnabled.value) return;
    try {
      await _playersReady;
      await _pencilWritingPlayer.stop();
      await _pencilWritingPlayer.setReleaseMode(ReleaseMode.loop);
      await _pencilWritingPlayer.play(
        AssetSource('music/pencil_writing.mp3'),
        volume: 0.6,
      );
    } catch (error) {
      debugPrint('SoundEffectsController: pencil sound failed: $error');
    }
  }

  Future<void> stopPencilWriting() async {
    try {
      await _pencilWritingPlayer.stop();
      await _pencilWritingPlayer.setReleaseMode(ReleaseMode.stop);
    } catch (_) {}
  }

  // ============================================================
  // STORM SOUND (rain + thunder), cut to match the animation
  // ============================================================
  Future<void> _debugCheckAsset(String asset) async {
    try {
      final data = await rootBundle
          .load('assets/$asset')
          .timeout(const Duration(seconds: 5));
      debugPrint(
        'STORM DEBUG: asset OK $asset, '
        '${(data.lengthInBytes / 1024).toStringAsFixed(0)} KB',
      );
    } catch (e) {
      debugPrint('STORM DEBUG: asset FAILED assets/$asset -> $e');
    }
  }

  Future<void> playStorm({
    required List<double> strikeTimes, // seconds after tap
    double totalSeconds = 4.0, // length of the rain animation
    double thunderDelay = 0.3, // thunder comes after the flash
  }) async {
    if (!isSoundEffectsEnabled.value) return;

    try {
      await _playersReady;
      await stopStorm();

      // --- RAIN: play, then fade out when the animation ends ---
      final rainToken = ++_rainToken;
      await _rainPlayer.play(
        AssetSource(_rainAsset),
        volume: 0.6,
        position: _rainStartAt,
      );

      const rainFadeMs = 700;
      _later(
        Duration(milliseconds: (totalSeconds * 1000).round() - rainFadeMs),
        () => _fadeOutAndStop(
          _rainPlayer,
          from: 0.6,
          ms: rainFadeMs,
          isStale: () => rainToken != _rainToken,
        ),
      );

      // --- THUNDER: one short piece for each flash ---
      for (int i = 0; i < strikeTimes.length; i++) {
        final isLast = i == strikeTimes.length - 1;
        final start = strikeTimes[i] + thunderDelay;

        // play until the next thunder starts (last one gets more time)
        final end = isLast ? start + 2.0 : strikeTimes[i + 1] + thunderDelay;
        final length = ((end - start) + 0.7).clamp(0.5, 2.8);

        _later(
          Duration(milliseconds: (start * 1000).round()),
          () => _playThunderPiece(length: length, volume: isLast ? 1.0 : 0.7),
        );
      }

      _resumeBackgroundMusicSoon();
    } catch (error) {
      debugPrint('SoundEffectsController: storm sound failed: $error');
    }
  }

  Future<void> _playThunderPiece({
    required double length,
    required double volume,
  }) async {
    try {
      final token = ++_thunderToken;
      await _thunderPlayer.stop();
      await _thunderPlayer.play(
        AssetSource(_thunderAsset),
        volume: volume,
        position: _thunderStartAt,
      );

      final fadeMs = (length * 1000 * 0.4).round().clamp(150, 500);
      _later(
        Duration(milliseconds: (length * 1000).round() - fadeMs),
        () => _fadeOutAndStop(
          _thunderPlayer,
          from: volume,
          ms: fadeMs,
          isStale: () => token != _thunderToken,
        ),
      );
    } catch (_) {}
  }

  Future<void> _fadeOutAndStop(
    AudioPlayer player, {
    required double from,
    required int ms,
    required bool Function() isStale,
  }) async {
    const steps = 8;
    try {
      for (int i = 1; i <= steps; i++) {
        await Future.delayed(Duration(milliseconds: ms ~/ steps));
        if (isStale()) return; // a newer sound started, do not touch it
        await player.setVolume(from * (1 - i / steps));
      }
      if (isStale()) return;
      await player.stop();
    } catch (_) {}
  }

  void _later(Duration delay, void Function() action) {
    _stormTimers.add(Timer(delay, action));
  }

  /// Stops all storm sounds right away (used when leaving the screen).
  Future<void> stopStorm() async {
    for (final t in _stormTimers) {
      t.cancel();
    }
    _stormTimers.clear();
    _rainToken++;
    _thunderToken++;
    try {
      await _rainPlayer.stop();
      await _thunderPlayer.stop();
    } catch (_) {}
  }

  void _resumeBackgroundMusicSoon() {
    Future.delayed(const Duration(milliseconds: 250), () {
      if (Get.isRegistered<MusicController>()) {
        Get.find<MusicController>().resumeIfNeeded();
      }
    });
  }

  @override
  void onClose() {
    for (final t in _stormTimers) {
      t.cancel();
    }
    _pageFlipPlayer.dispose();
    _bookOpeningPlayer.dispose();
    _leafAppearPlayer.dispose();
    _pencilWritingPlayer.dispose();
    _rainPlayer.dispose();
    _thunderPlayer.dispose();

    super.onClose();
  }
}
