import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:lumina/core/service/ai_service.dart';
import 'package:lumina/core/service/consent_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:lumina/core/routes/model/journel_entry_model.dart';

class JournalService {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();
  final _aiService = AiService();
  final _consentService = ConsentService();

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
    final finalImagePaths = await _uploadImages(docId, entry.imagePaths);

    // ── Save to Firestore immediately with tagging_status = pending ──
    final toSave = entry.copyWith(
      id: docId,
      imagePaths: finalImagePaths,
      isPhotoProtected: entry.isPhotoProtected || finalImagePaths.isNotEmpty,
      taggingStatus: 'pending',
    );
    await _entriesRef.doc(docId).set(toSave.toMap());

    // ── Check consent before tagging ────────────────────────
    final hasConsented = await _consentService.hasConsented();

    if (hasConsented) {
      _tagEntryInBackground(docId: docId, entry: toSave);
    } else {
      final agreed = await _showConsentDialog();
      if (agreed) {
        await _consentService.saveConsent(true);
        _tagEntryInBackground(docId: docId, entry: toSave);
      } else {
        await _entriesRef.doc(docId).update({
          'tags': {},
          'taggingStatus': 'skipped',
          'inferenceSource': 'none',
        });
      }
    }

    return toSave;
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
    Future(() async {
      try {
        final result = await _aiService.tagMemory(
          question: entry.question,
          answer: entry.body ?? '',
        );

        final tags = result['tags'] as Map<String, dynamic>;
        final inferenceSource = result['inferenceSource'] as String;

        await _entriesRef.doc(docId).update({
          'tags': tags,
          'taggingStatus': 'complete',
          'inferenceSource': inferenceSource,
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

  Stream<List<JournalEntry>> streamEntries() {
    final uid = _uid;
    if (uid == null) return Stream.value(<JournalEntry>[]);

    return _entriesRef.orderBy('date', descending: false).snapshots().map((
      snap,
    ) {
      return snap.docs
          .map((doc) => JournalEntry.fromMap(doc.id, doc.data()))
          .toList();
    });
  }
}