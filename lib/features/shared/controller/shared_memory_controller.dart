import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:lumina/core/controller/journal_controller.dart';
import 'package:lumina/core/routes/model/journel_entry_model.dart';
import 'package:lumina/features/auth/service/journal_service.dart';
import 'package:lumina/features/shared/controller/shared_controller.dart';
import 'package:lumina/features/shared/model/shared_model.dart';

class SharedMemoryController extends GetxController {
  final CollectionReference<Map<String, dynamic>> _sharedMemoriesCollection =
      FirebaseFirestore.instance.collection('sharedMemories');

  final RxList<SharedPage> receivedPages = <SharedPage>[].obs;
  final RxList<SharedPage> sentPages = <SharedPage>[].obs;

  final RxnString selectedEntryId = RxnString();
  final Rxn<TrustedPerson> personToShareWith = Rxn<TrustedPerson>();

  StreamSubscription<User?>? _authSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _receivedSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sentSub;

  @override
  void onInit() {
    super.onInit();
    _loadSharedMemories();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _loadSharedMemories();
      } else {
        receivedPages.clear();
        sentPages.clear();
        _receivedSub?.cancel();
        _sentSub?.cancel();
      }
    });
  }

  Future<void> _loadSharedMemories() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await Future.wait([_loadSentPages(user), _loadReceivedPages(user)]);
    _listenForIncomingShares(user);
    _listenForSentMemoryUpdates(user);
  }

  Future<void> _loadSentPages(User user) async {
    try {
      final query = await _sharedMemoriesCollection
          .where('fromUid', isEqualTo: user.uid)
          .get();
      sentPages.assignAll(
        query.docs
            .map((doc) => _pageFromDoc(doc, SharedDirection.sent))
            .whereType<SharedPage>(),
      );
    } catch (_) {}
  }

  Future<void> _loadReceivedPages(User user) async {
    try {
      final query = await _sharedMemoriesCollection
          .where('toUid', isEqualTo: user.uid)
          .get();
      receivedPages.assignAll(
        query.docs
            .map((doc) => _pageFromDoc(doc, SharedDirection.received))
            .whereType<SharedPage>(),
      );
    } catch (_) {}
  }

  void _listenForIncomingShares(User user) {
    _receivedSub?.cancel();
    _receivedSub = _sharedMemoriesCollection
        .where('toUid', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
          for (final change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.removed) {
              receivedPages.removeWhere((p) => p.id == change.doc.id);
              continue;
            }

            if (change.type == DocumentChangeType.modified) {
              final page = _pageFromDoc(change.doc, SharedDirection.received);
              if (page == null) {
                receivedPages.removeWhere((p) => p.id == change.doc.id);
                continue;
              }
              final index = receivedPages.indexWhere((p) => p.id == page.id);
              if (index != -1) receivedPages[index] = page;
              continue;
            }

            if (receivedPages.any((p) => p.id == change.doc.id)) continue;
            final page = _pageFromDoc(change.doc, SharedDirection.received);
            if (page == null) continue;
            receivedPages.insert(0, page);
          }
        });
  }

  void _listenForSentMemoryUpdates(User user) {
    _sentSub?.cancel();
    _sentSub = _sharedMemoriesCollection
        .where('fromUid', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
          for (final change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.removed) {
              sentPages.removeWhere((p) => p.id == change.doc.id);
              continue;
            }

            final page = _pageFromDoc(change.doc, SharedDirection.sent);
            if (page == null) {
              sentPages.removeWhere((p) => p.id == change.doc.id);
              continue;
            }
            final index = sentPages.indexWhere((p) => p.id == page.id);
            if (index != -1) {
              sentPages[index] = page;
            } else if (change.type == DocumentChangeType.added) {
              sentPages.insert(0, page);
            }
          }
        });
  }

  SharedPage? _pageFromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SharedDirection direction,
  ) {
    final data = doc.data();
    if (data == null) return null;
    final senderDeleted = data['senderDeleted'] as bool? ?? false;
    final receiverDeleted = data['receiverDeleted'] as bool? ?? false;
    if (direction == SharedDirection.sent && senderDeleted) return null;
    if (direction == SharedDirection.received && receiverDeleted) return null;

    final fromName = (data['fromName'] as String?)?.trim();
    final fromUid = (data['fromUid'] as String?)?.trim() ?? '';
    final toName = (data['toName'] as String?)?.trim();
    final toUid = (data['toUid'] as String?)?.trim() ?? '';
    final dateTimestamp = data['date'] as Timestamp?;
    final sharedAtTimestamp = data['sharedAt'] as Timestamp?;
    return SharedPage(
      id: doc.id,
      personId: direction == SharedDirection.sent ? toUid : fromUid,
      question: (data['question'] as String?)?.trim() ?? '',
      body: (data['body'] as String?)?.trim(),
      date: dateTimestamp?.toDate() ?? DateTime.now(),
      sharedAt: sharedAtTimestamp?.toDate(), // ← new
      personName: direction == SharedDirection.sent
          ? (toName ?? 'Friend')
          : (fromName ?? 'Friend'),
      direction: direction,
      isSeen: data['isSeen'] as bool? ?? false,
      imagePaths: List<String>.from(data['imagePaths'] as List? ?? []),
      chapterId: (data['chapterId'] as String?)?.trim() ?? '',
      questionId: (data['questionId'] as String?)?.trim() ?? '',
    );
  }

  void startShareFlow(TrustedPerson person) {
    personToShareWith.value = person;
    final entries = Get.find<JournalController>().entries;
    selectedEntryId.value = entries.isNotEmpty ? entries.first.id : null;
  }

  void selectEntry(String id) {
    selectedEntryId.value = id;
  }

  Future<void> shareEntryDirectly(
    JournalEntry entry,
    TrustedPerson person,
  ) async {
    personToShareWith.value = person;
    selectedEntryId.value = entry.id;
    await confirmShare();
  }

  /// Confirms and creates the shared memory.
  Future<void> confirmShare() async {
    final user = FirebaseAuth.instance.currentUser;
    final person = personToShareWith.value;
    final entryId = selectedEntryId.value;

    if (user == null || person == null || entryId == null) return;

    final JournalEntry? entry = Get.find<JournalController>().entries
        .firstWhereOrNull((e) => e.id == entryId);

    if (entry == null) return;

    final bool hasImages = entry.imagePaths.isNotEmpty;

    // ── paywall checks ────────────────────────────────────────────
    // ── end paywall checks ────────────────────────────────────────

    final sharedController = Get.find<SharedController>();

    try {
      final imageUrls = hasImages
          ? await JournalService().uploadImagesForSharing(entry)
          : entry.imagePaths;
      final doc = await _sharedMemoriesCollection.add({
        'fromUid': user.uid,
        'fromName': sharedController.currentDisplayName.value.isNotEmpty
            ? sharedController.currentDisplayName.value
            : sharedController.currentUsername.value,
        'toUid': person.id,
        'toName': person.name,
        'chapterId': entry.chapterId,
        'questionId': entry.questionId,
        'question': entry.question,
        'body': entry.body,
        'imagePaths': imageUrls,
        'date': Timestamp.fromDate(entry.date),
        'isSeen': false,
        'senderDeleted': false,
        'receiverDeleted': false,
        'sharedAt': FieldValue.serverTimestamp(),
      });

      sentPages.insert(
        0,
        SharedPage(
          id: doc.id,
          personId: person.id,
          question: entry.question,
          body: entry.body,
          date: entry.date,
          personName: person.name,
          direction: SharedDirection.sent,
          isSeen: false,
          imagePaths: imageUrls,
          chapterId: entry.chapterId,
          questionId: entry.questionId,
        ),
      );

      personToShareWith.value = null;
      selectedEntryId.value = null;

      Get.snackbar('Shared', 'Journal entry shared with ${person.name}');
    } catch (_) {
      Get.snackbar('Failed', 'Could not share entry. Try again later.');
    }
  }

  Future<void> markAsSeen(SharedPage page) async {
    if (page.direction != SharedDirection.received) return;
    if (page.isSeen) return;
    try {
      await _sharedMemoriesCollection.doc(page.id).update({'isSeen': true});
      final index = receivedPages.indexWhere((p) => p.id == page.id);
      if (index != -1) {
        receivedPages[index] = SharedPage(
          id: page.id,
          personId: page.personId,
          question: page.question,
          date: page.date,
          personName: page.personName,
          direction: page.direction,
          isNew: page.isNew,
          isSeen: true,
          body: page.body,
          imagePaths: page.imagePaths,
          chapterId: page.chapterId,
          questionId: page.questionId,
        );
      }
    } catch (_) {}
  }

  Future<bool> deleteSharedPage(
    SharedPage page,
    SharedDeleteScope scope,
  ) async {
    try {
      if (scope == SharedDeleteScope.forEveryone) {
        await _sharedMemoriesCollection.doc(page.id).delete();
        receivedPages.removeWhere((p) => p.id == page.id);
        sentPages.removeWhere((p) => p.id == page.id);
        return true;
      }

      final deletedField = page.direction == SharedDirection.received
          ? 'receiverDeleted'
          : 'senderDeleted';

      await _sharedMemoriesCollection.doc(page.id).update({
        deletedField: true,
        '${deletedField}At': FieldValue.serverTimestamp(),
      });

      if (page.direction == SharedDirection.received) {
        receivedPages.removeWhere((p) => p.id == page.id);
      } else {
        sentPages.removeWhere((p) => p.id == page.id);
      }
      return true;
    } catch (_) {
      Get.snackbar(
        'Couldn\'t delete',
        'The memory could not be deleted. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  List<SharedPage> pagesReceivedFrom(String personName) {
    return receivedPages.where((p) => p.personName == personName).toList();
  }

  List<SharedPage> pagesSharedWith(String personId) {
    final pages = [
      ...receivedPages.where((p) => p.personId == personId),
      ...sentPages.where((p) => p.personId == personId),
    ]..sort((a, b) => b.date.compareTo(a.date));

    return pages;
  }

  int sharedMemoriesCountFor(String personId) {
    return pagesSharedWith(personId).length;
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _receivedSub?.cancel();
    _sentSub?.cancel();
    super.onClose();
  }
}
