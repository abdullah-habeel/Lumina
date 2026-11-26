import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:lumina/core/service/ai_service.dart';
import 'package:lumina/core/service/consent_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:lumina/core/routes/model/journel_entry_model.dart';

class JournalService {
  static const _syncTimeout = Duration(seconds: 20);

  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();
  final _aiService = AiService();
  final _consentService = ConsentService();
  bool _isSyncing = false;
  bool _syncRequestedWhileRunning = false;
  final Set<String> _taggingInProgress = {};

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _entriesRef {
    final uid = _uid;
    if (uid == null) throw Exception('No signed-in user.');
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('journal_entries');
  }

  String _docIdFor(JournalEntry entry) {
    return entry.id ?? '${entry.chapterId}_${entry.questionId}';
  }

  String _pendingEntriesKey(String uid) => 'journal_pending_entries_$uid';

  Future<List<JournalEntry>> _loadPendingEntries(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_pendingEntriesKey(uid));
    if (encoded == null || encoded.isEmpty) return [];

    final decoded = jsonDecode(encoded);
    if (decoded is! List) {
      throw const FormatException('Pending journal entries must be a list.');
    }

    return decoded.map((value) {
      if (value is! Map) {
        throw const FormatException('Invalid pending journal entry.');
      }
      final map = Map<String, dynamic>.from(value);
      final id = map.remove('id') as String?;
      final date = map['date'] as String?;
      if (id == null || date == null) {
        throw const FormatException('Pending journal entry is missing fields.');
      }
      map['date'] = Timestamp.fromDate(DateTime.parse(date));
      return JournalEntry.fromMap(id, map);
    }).toList();
  }

  Future<void> _writePendingEntries(
    String uid,
    List<JournalEntry> entries,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      entries.map((entry) {
        final map = entry.toMap();
        map['id'] = _docIdFor(entry);
        map['date'] = entry.date.toIso8601String();
        map['echoInferenceSource'] = entry.echoInferenceSource;
        return map;
      }).toList(),
    );
    final stored = await prefs.setString(_pendingEntriesKey(uid), encoded);
    if (!stored) {
      throw StateError('Could not persist pending journal entries.');
    }
  }

  Future<void> _upsertPendingEntry(JournalEntry entry) async {
    final uid = _uid;
    if (uid == null) throw StateError('No signed-in user.');

    final entries = await _loadPendingEntries(uid);
    final index = entries.indexWhere(
      (pending) => _docIdFor(pending) == _docIdFor(entry),
    );
    if (index >= 0) {
      entries[index] = entry;
    } else {
      entries.add(entry);
    }
    await _writePendingEntries(uid, entries);
  }

  Future<void> _removePendingEntry(String uid, String docId) async {
    final entries = await _loadPendingEntries(uid);
    entries.removeWhere((entry) => _docIdFor(entry) == docId);
    await _writePendingEntries(uid, entries);
  }

  Future<bool> _hasNetworkConnection() async {
    final results = await Connectivity().checkConnectivity();
    return results.any((result) => result != ConnectivityResult.none);
  }

  Future<File> _compressImage(File original) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath =
        '${tempDir.path}/journal_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      original.absolute.path,
      targetPath,
      quality: 75,
      minWidth: 1080,
      minHeight: 1080,
      format: CompressFormat.jpeg,
    );

    if (result == null) return original;
    return File(result.path);
  }

  Future<List<String>> _uploadImages(
    String docId,
    List<String> localPaths,
  ) async {
    final uid = _uid;
    if (uid == null) throw StateError('No signed-in user.');

    final urls = <String>[];
    for (final path in localPaths) {
      if (path.startsWith('http://') || path.startsWith('https://')) {
        urls.add(path);
        continue;
      }

      final compressedFile = await _compressImage(File(path));
      debugPrint(
        'JOURNAL IMAGE: compressed to ${(compressedFile.lengthSync() / 1024).toStringAsFixed(1)} KB',
      );

      final ref = _storage.ref().child(
        'users/$uid/journal_images/$docId/${_uuid.v4()}.jpg',
      );
      await ref.putFile(compressedFile);
      urls.add(await ref.getDownloadURL());
    }
    return urls;
  }

  Future<List<String>> uploadImagesForSharing(JournalEntry entry) async {
    final docId = _docIdFor(entry);
    final imageUrls = await _uploadImages(docId, entry.imagePaths);

    if (entry.imagePaths.isNotEmpty) {
      final updatedEntry = entry.copyWith(
        imagePaths: imageUrls,
        isPhotoProtected: true,
      );
      await _entriesRef
          .doc(docId)
          .set(updatedEntry.toMap(), SetOptions(merge: true));
    }

    return imageUrls;
  }

  Future<JournalEntry> saveEntry(JournalEntry entry) async {
    final docId = _docIdFor(entry);
    final toSave = entry.copyWith(
      id: docId,
      isPhotoProtected: entry.isPhotoProtected || entry.imagePaths.isNotEmpty,
      taggingStatus: 'pending',
    );
    await _upsertPendingEntry(toSave);

    // ── Check consent before tagging ────────────────────────
    final hasConsented = await _consentService.hasConsented();

    if (!hasConsented) {
      final agreed = await _showConsentDialog();
      if (agreed) {
        await _consentService.saveConsent(true);
      } else {
        final skippedEntry = toSave.copyWith(
          tags: {},
          taggingStatus: 'skipped',
          inferenceSource: 'none',
        );
        await _markTaggingSkipped(skippedEntry);
      }
    }

    unawaited(syncPendingEntries());
    return toSave;
  }

  Future<void> _markTaggingSkipped(JournalEntry entry) async {
    final uid = _uid;
    if (uid == null) throw StateError('No signed-in user.');

    final pending = await _loadPendingEntries(uid);
    final isPending = pending.any(
      (item) => _docIdFor(item) == _docIdFor(entry),
    );
    if (isPending) {
      await _upsertPendingEntry(entry);
      return;
    }

    try {
      await _entriesRef
          .doc(_docIdFor(entry))
          .update({
            'tags': {},
            'taggingStatus': 'skipped',
            'inferenceSource': 'none',
          })
          .timeout(_syncTimeout);
    } catch (error) {
      debugPrint('JOURNAL_SERVICE: Could not update tagging status — $error');
      await _upsertPendingEntry(entry);
    }
  }

  Future<JournalEntry> _syncEntryToCloud(JournalEntry entry) async {
    final uid = _uid;
    if (uid == null) throw StateError('No signed-in user.');

    final docId = _docIdFor(entry);
    final uploadedImagePaths = await _uploadImages(docId, entry.imagePaths);
    final latestPending = (await _loadPendingEntries(
      uid,
    )).where((pending) => _docIdFor(pending) == docId);
    final entryToSync = latestPending.isEmpty ? entry : latestPending.first;
    final syncedEntry = entryToSync.copyWith(
      id: docId,
      imagePaths: uploadedImagePaths,
      isPhotoProtected:
          entryToSync.isPhotoProtected || uploadedImagePaths.isNotEmpty,
    );
    await _entriesRef.doc(docId).set(syncedEntry.toMap()).timeout(_syncTimeout);
    await _removePendingEntry(uid, docId);
    return syncedEntry;
  }

  Future<void> syncPendingEntries() async {
    if (_isSyncing) {
      _syncRequestedWhileRunning = true;
      return;
    }
    final uid = _uid;
    if (uid == null) return;

    _isSyncing = true;
    try {
      if (!await _hasNetworkConnection()) return;

      final pendingEntries = await _loadPendingEntries(uid);
      for (final entry in pendingEntries) {
        try {
          final syncedEntry = await _syncEntryToCloud(entry);
          if (syncedEntry.taggingStatus == 'pending' &&
              await _consentService.hasConsented()) {
            _tagEntryInBackground(
              docId: _docIdFor(syncedEntry),
              entry: syncedEntry,
            );
          }
        } catch (error) {
          debugPrint(
            'JOURNAL_SERVICE: Could not sync entry ${_docIdFor(entry)} — $error',
          );
        }
      }
    } catch (error) {
      debugPrint('JOURNAL_SERVICE: Pending sync failed — $error');
    } finally {
      _isSyncing = false;
      if (_syncRequestedWhileRunning) {
        _syncRequestedWhileRunning = false;
        unawaited(syncPendingEntries());
      }
    }
  }

  Future<bool> _showConsentDialog() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('AI Memory Tagging'),
        content: const Text(
          'Lumina uses AI to tag your memories with emotions, themes, and keywords.\n\n'
          'On supported devices, this runs entirely on your device.\n\n'
          'On unsupported devices, your memory is sent to Google\'s servers via Firebase AI Logic for processing.\n\n'
          'Do you agree to allow this?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('No thanks'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('I agree'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }

  /// Runs after save completes. Updates the Firestore doc with tags.
  /// Any failure is caught silently — memory is already saved.
  void _tagEntryInBackground({
    required String docId,
    required JournalEntry entry,
  }) {
    if (!_taggingInProgress.add(docId)) return;

    Future(() async {
      try {
        final result = await _aiService.tagMemory(
          question: entry.question,
          answer: entry.body ?? '',
        );
        final tags = result['tags'] as Map<String, dynamic>;
        final inferenceSource = result['inferenceSource'] as String;
        final significanceScore = (tags['significanceScore'] as num?)?.toInt();
        final echoQuestion = result['echoQuestion'] as String?;
        final echoInferenceSource = result['echoInferenceSource'] as String?;

        await _entriesRef.doc(docId).update({
          'tags': tags,
          'taggingStatus': 'complete',
          'inferenceSource': inferenceSource,
          'significanceScore': significanceScore,
          'echoQuestion': echoQuestion,
          'echoInferenceSource': echoInferenceSource,
        });

        debugPrint(
          'JOURNAL_SERVICE: Tagged entry $docId — source: $inferenceSource',
        );
      } catch (e) {
        debugPrint('JOURNAL_SERVICE: Background tagging failed — $e');
        try {
          await _entriesRef.doc(docId).update({
            'tags': {},
            'taggingStatus': 'failed',
            'inferenceSource': 'failed',
          });
        } catch (_) {}
      } finally {
        _taggingInProgress.remove(docId);
      }
    });
  }

  Future<void> uploadAllLocalPhotos() async {
    final snap = await _entriesRef.get();
    for (final doc in snap.docs) {
      final entry = JournalEntry.fromMap(doc.id, doc.data());
      final hasLocal = entry.imagePaths.any((p) => !p.startsWith('http'));
      if (!hasLocal) continue;

      final uploaded = await _uploadImages(doc.id, entry.imagePaths);
      final updated = entry.copyWith(
        imagePaths: uploaded,
        isPhotoProtected: true,
      );
      await _entriesRef.doc(doc.id).set(updated.toMap());
    }
  }

  Future<void> deleteEntry(JournalEntry entry) async {
    final docId = _docIdFor(entry);
    await _entriesRef.doc(docId).delete();

    for (final path in entry.imagePaths) {
      if (path.startsWith('http')) {
        try {
          await _storage.refFromURL(path).delete();
        } catch (_) {}
      } else if (path.startsWith('/')) {
        try {
          final file = File(path);
          if (file.existsSync()) file.deleteSync();
        } catch (_) {}
      }
    }
  }

  Stream<List<JournalEntry>> streamEntries() async* {
    final uid = _uid;
    if (uid == null) {
      yield <JournalEntry>[];
      return;
    }

    yield await _loadPendingEntries(uid);
    await for (final snap
        in _entriesRef
            .orderBy('date', descending: false)
            .snapshots(includeMetadataChanges: true)) {
      if (!snap.metadata.isFromCache) {
        unawaited(syncPendingEntries());
      }
      final entries = {
        for (final doc in snap.docs)
          doc.id: JournalEntry.fromMap(doc.id, doc.data()),
      };
      for (final pending in await _loadPendingEntries(uid)) {
        entries[_docIdFor(pending)] = pending;
      }
      final merged = entries.values.toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      yield merged;
    }
  }
}
