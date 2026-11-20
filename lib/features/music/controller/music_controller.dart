import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:lumina/features/music/model/music_model.dart';

class MusicController extends GetxService {
  final AudioPlayer _player = AudioPlayer();

  final List<MusicTrack> availableTracks = const [
    MusicTrack(
      id: 'track_one',
      title: 'Gentle Pages',
      assetPath: 'music/documentary_loop.mp3',
    ),
    MusicTrack(
      id: 'track_two',
      title: 'Warm Ink',
      assetPath: 'music/peaceful_piano.mp3',
    ),
  ];

  static const String _defaultTrackId = 'track_two';

  final RxString selectedTrackId = _defaultTrackId.obs;
  final RxBool isMusicEnabled = true.obs;
  final RxBool isPlaying = false.obs;

  int _activeScreenCount = 0;

  String? _currentlyLoadedTrackId;

  // Remembers whether music was playing before the app went
  // into the background.
  bool _wasPlayingBeforeBackground = false;

  // Prevents a delayed screen operation from restarting music
  // while the app is in background.
  bool _isAppInBackground = false;

  MusicTrack? get selectedTrack {
    return availableTracks.firstWhereOrNull(
      (t) => t.id == selectedTrackId.value,
    );
  }

  @override
  void onInit() {
    super.onInit();

    _player.setReleaseMode(ReleaseMode.loop);

    loadPreference();
  }

  /// Load user's saved music preferences.
  Future<void> loadPreference() async {
    try {
      if (Firebase.apps.isEmpty) return;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;

        final savedTrackId = (data['selectedMusicTrackId'] as String?) ?? '';

        final savedEnabled = data['isMusicEnabled'] as bool?;

        final savedTrack = availableTracks.firstWhereOrNull(
          (t) => t.id == savedTrackId,
        );

        selectedTrackId.value = savedTrack?.id ?? _defaultTrackId;

        if (savedEnabled != null) {
          isMusicEnabled.value = savedEnabled;
        }
      } else {
        selectedTrackId.value = _defaultTrackId;
      }
    } catch (_) {
      // Keep defaults if Firebase fails.
    }
  }

  /// Select another background music track.
  Future<void> selectTrack(String trackId) async {
    if (selectedTrackId.value == trackId) return;

    selectedTrackId.value = trackId;

    await _savePreference();

    if (_activeScreenCount > 0 && isMusicEnabled.value && !_isAppInBackground) {
      await _play();
    }
  }

  /// Enable/disable background music.
  Future<void> toggleMusicEnabled(bool enabled) async {
    isMusicEnabled.value = enabled;

    await _savePreference();

    if (!enabled) {
      await _player.pause();
      isPlaying.value = false;
      _wasPlayingBeforeBackground = false;
    } else if (_activeScreenCount > 0 && !_isAppInBackground) {
      await _play();
    }
  }

  Future<void> _savePreference() async {
    try {
      if (Firebase.apps.isEmpty) return;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'selectedMusicTrackId': selectedTrackId.value,
        'isMusicEnabled': isMusicEnabled.value,
      }, SetOptions(merge: true));
    } catch (_) {
      // Non-critical.
    }
  }

  // ============================================================
  // SCREEN MUSIC MANAGEMENT
  // ============================================================

  /// Call when a screen that should play music is opened.
  Future<void> enterMusicScreen() async {
    _activeScreenCount++;

    if (_isAppInBackground) return;

    if (isMusicEnabled.value && selectedTrack != null) {
      await _play();
    }
  }

  /// Call when a screen that should play music is closed.
  Future<void> exitMusicScreen() async {
    _activeScreenCount--;

    if (_activeScreenCount < 0) {
      _activeScreenCount = 0;
    }

    // Only stop when NO music screens remain.
    if (_activeScreenCount == 0) {
      await _player.pause();
      isPlaying.value = false;
    }
  }

  // ============================================================
  // APP LIFECYCLE MANAGEMENT
  // ============================================================

  /// Called when the entire application goes into background.
  Future<void> pauseForBackground() async {
    _isAppInBackground = true;

    // Remember whether music was actually playing.
    _wasPlayingBeforeBackground = isPlaying.value;

    // IMPORTANT:
    // Pause immediately. Do NOT use exitMusicScreen() here.
    try {
      await _player.pause();
    } catch (_) {
      // Ignore audio errors.
    }

    isPlaying.value = false;
  }

  /// Called when the application returns to foreground.
  Future<void> resumeFromBackground() async {
    _isAppInBackground = false;

    // Only restart if music was actually playing before
    // the application went to background.
    if (!_wasPlayingBeforeBackground) {
      return;
    }

    if (!isMusicEnabled.value) {
      return;
    }

    if (_activeScreenCount <= 0) {
      return;
    }

    final track = selectedTrack;

    if (track == null) {
      return;
    }

    try {
      if (_currentlyLoadedTrackId == track.id) {
        await _player.resume();
        isPlaying.value = true;
      } else {
        await _play();
      }
    } catch (_) {
      // Ignore playback errors.
    }

    _wasPlayingBeforeBackground = false;
  }

  /// Backward-compatible method if you use it elsewhere.
  Future<void> resumeIfNeeded() async {
    await resumeFromBackground();
  }

  // ============================================================
  // AUDIO
  // ============================================================

  Future<void> _play() async {
    if (_isAppInBackground) return;

    final track = selectedTrack;

    if (track == null) return;

    if (isPlaying.value && _currentlyLoadedTrackId == track.id) {
      return;
    }

    try {
      await _player.play(AssetSource(track.assetPath));

      _currentlyLoadedTrackId = track.id;
      isPlaying.value = true;
    } catch (_) {
      // Ignore playback errors.
    }
  }

  @override
  void onClose() {
    _player.stop();
    _player.dispose();

    super.onClose();
  }
}
