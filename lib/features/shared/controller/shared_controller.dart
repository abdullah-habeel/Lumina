import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:lumina/features/shared/model/shared_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

/// Handles friend requests and the trusted-people list.
/// Journal memory sharing lives in SharedMemoryController.
class SharedController extends GetxController {
  final CollectionReference<Map<String, dynamic>> _usersCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference<Map<String, dynamic>> _friendRequestsCollection =
      FirebaseFirestore.instance.collection('friendRequests');

  final RxList<TrustedPerson> trustedPeople = <TrustedPerson>[].obs;
  final RxList<ConnectionRequest> incomingRequests = <ConnectionRequest>[].obs;
  final RxList<TrustedPerson> suggestedPeople = <TrustedPerson>[].obs;

  /// Requests you sent that were accepted and you haven't seen yet.
  final RxList<AcceptedRequestNotice> recentlyAcceptedRequests =
      <AcceptedRequestNotice>[].obs;

  final RxString searchQuery = ''.obs;
  final RxString currentUsername = ''.obs;
  final RxString currentDisplayName = ''.obs;
  final RxBool isLoading = true.obs;
  final RxString backendError = ''.obs;

  final RxList<String> acceptedFriendIds = <String>[].obs;
  final RxList<String> pendingOutgoingUserIds = <String>[].obs;
  final RxList<String> pendingIncomingUserIds = <String>[].obs;

  final Set<String> _seenAcceptedRequestIds = {};

  String _seenAcceptedPrefsKey(String uid) => 'accepted_seen_ids_$uid';

  StreamSubscription<User?>? _authSub;

  @override
  void onInit() {
    super.onInit();
    _loadBackendData();

    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _loadBackendData();
      } else {
        trustedPeople.clear();
        incomingRequests.clear();
        suggestedPeople.clear();
        recentlyAcceptedRequests.clear();
        acceptedFriendIds.clear();
        pendingOutgoingUserIds.clear();
        pendingIncomingUserIds.clear();
        _seenAcceptedRequestIds.clear();
      }
    });
  }

  Future<void> _loadBackendData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      isLoading.value = false;
      return;
    }

    await _loadSeenAcceptedIds(user.uid);
    await _loadCurrentUser(user);
    await Future.wait([
      _loadIncomingRequests(user),
      _loadPendingOutgoingRequests(user),
      _loadTrustedPeople(user),
    ]);
    await _persistSeenAcceptedIds(user.uid);
    await _loadSuggestedPeople(user);

    _listenForAcceptedOutgoingRequests(user);

    isLoading.value = false;
  }

  Future<void> _loadSeenAcceptedIds(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_seenAcceptedPrefsKey(uid)) ?? [];
    _seenAcceptedRequestIds
      ..clear()
      ..addAll(stored);
  }

  Future<void> _persistSeenAcceptedIds(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _seenAcceptedPrefsKey(uid),
      _seenAcceptedRequestIds.toList(),
    );
  }

  Future<void> _loadCurrentUser(User user) async {
    final localPart = user.email?.split('@').first ?? '';
    currentDisplayName.value = user.displayName?.trim() ?? '';
    currentUsername.value = localPart;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final username = (data['username'] as String?)?.trim();
        final displayName = (data['displayName'] as String?)?.trim();
        final email = (data['email'] as String?)?.trim();

        if (username != null && username.isNotEmpty) {
          currentUsername.value = username;
        }

        if (displayName != null && displayName.isNotEmpty) {
          currentDisplayName.value = displayName;
        } else if (currentDisplayName.value.isEmpty &&
            username != null &&
            username.isNotEmpty) {
          currentDisplayName.value = username;
        } else if (currentDisplayName.value.isEmpty &&
            email != null &&
            email.isNotEmpty) {
          currentDisplayName.value = email.split('@').first;
        }
      }
    } catch (_) {
      backendError.value = 'Unable to load your profile';
    }
  }

  Future<void> _loadIncomingRequests(User user) async {
    try {
      final query = await _friendRequestsCollection
          .where('toUid', isEqualTo: user.uid)
          .where('status', isEqualTo: 'pending')
          .get();

      final requests = query.docs.map((doc) {
        final data = doc.data();
        final fromName = (data['fromName'] as String?)?.trim();
        final fromUsername = (data['fromUsername'] as String?)?.trim();
        final fromUid = (data['fromUid'] as String?)?.trim() ?? '';

        if (fromUid.isNotEmpty) {
          pendingIncomingUserIds.add(fromUid);
        }

        return ConnectionRequest(
          id: doc.id,
          fromUid: fromUid,
          name: fromName ?? fromUsername ?? 'Friend',
          username: fromUsername ?? 'unknown',
        );
      }).toList();

      incomingRequests.assignAll(requests);
    } catch (_) {
      backendError.value = 'Unable to load incoming requests';
    }
  }

  Future<void> _loadPendingOutgoingRequests(User user) async {
    try {
      final query = await _friendRequestsCollection
          .where('fromUid', isEqualTo: user.uid)
          .where('status', isEqualTo: 'pending')
          .get();

      for (final doc in query.docs) {
        final data = doc.data();
        final toUid = (data['toUid'] as String?)?.trim();
        if (toUid != null && toUid.isNotEmpty) {
          pendingOutgoingUserIds.add(toUid);
        }
      }
    } catch (_) {
      backendError.value = 'Unable to load outgoing requests';
    }
  }

  Future<void> _loadTrustedPeople(User user) async {
    try {
      final accepted = <TrustedPerson>[];

      final fromQuery = await _friendRequestsCollection
          .where('fromUid', isEqualTo: user.uid)
          .where('status', isEqualTo: 'accepted')
          .get();
      final toQuery = await _friendRequestsCollection
          .where('toUid', isEqualTo: user.uid)
          .where('status', isEqualTo: 'accepted')
          .get();

      for (final doc in [...fromQuery.docs, ...toQuery.docs]) {
        final data = doc.data();
        final fromUid = (data['fromUid'] as String?)?.trim();
        final toUid = (data['toUid'] as String?)?.trim();
        final fromName = (data['fromName'] as String?)?.trim();
        final fromUsername = (data['fromUsername'] as String?)?.trim();
        final toName = (data['toName'] as String?)?.trim();
        final toUsername = (data['toUsername'] as String?)?.trim();

        final isFromMe = fromUid == user.uid;
        final friendId = isFromMe ? toUid : fromUid;
        final friendName = isFromMe ? toName : fromName;
        final friendUsername = isFromMe ? toUsername : fromUsername;

        if (friendId != null && friendId.isNotEmpty) {
          final friendDoc = await _usersCollection.doc(friendId).get();
          final friendPhoto = (friendDoc.data()?['photoUrl'] as String?)
              ?.trim();

          print('=== FRIEND DEBUG ===');
          print('friendId: $friendId');
          print('friendDoc exists: ${friendDoc.exists}');
          print('friendDoc data: ${friendDoc.data()}');
          print('photoUrl: $friendPhoto');
          print('====================');

          acceptedFriendIds.add(friendId);
          accepted.add(
            TrustedPerson(
              id: friendId,
              name: friendName ?? friendUsername ?? 'Friend',
              username: friendUsername ?? 'unknown',
              sharedMemoriesCount: 0,
              photoUrl: friendPhoto,
            ),
          );
        }

        if (isFromMe) {
          if (!_seenAcceptedRequestIds.contains(doc.id)) {
            final respondedAtTimestamp = data['respondedAt'] as Timestamp?;
            recentlyAcceptedRequests.add(
              AcceptedRequestNotice(
                id: doc.id,
                friendName: friendName ?? friendUsername ?? 'Friend',
                respondedAt: respondedAtTimestamp?.toDate() ?? DateTime.now(),
              ),
            );
          }
          _seenAcceptedRequestIds.add(doc.id);
        }
      }

      trustedPeople.assignAll(accepted);
    } catch (_) {
      backendError.value = 'Unable to load trusted people';
    }
  }

  /// Live updates for requests YOU sent that get accepted while this
  /// session is running. Cold-start discoveries are handled above.
  void _listenForAcceptedOutgoingRequests(User user) {
    _friendRequestsCollection
        .where('fromUid', isEqualTo: user.uid)
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .listen((snapshot) async {
          var addedNew = false;

          for (final change in snapshot.docChanges) {
            final doc = change.doc;
            if (_seenAcceptedRequestIds.contains(doc.id)) continue;
            _seenAcceptedRequestIds.add(doc.id);
            addedNew = true;

            final data = doc.data();
            if (data == null) continue;

            final toName = (data['toName'] as String?)?.trim();
            final toUsername = (data['toUsername'] as String?)?.trim();
            final friendId = (data['toUid'] as String?)?.trim();
            final respondedAtTimestamp = data['respondedAt'] as Timestamp?;

            final friendName = toName?.isNotEmpty == true
                ? toName!
                : (toUsername?.isNotEmpty == true ? toUsername! : 'Someone');

            recentlyAcceptedRequests.add(
              AcceptedRequestNotice(
                id: doc.id,
                friendName: friendName,
                respondedAt: respondedAtTimestamp?.toDate() ?? DateTime.now(),
              ),
            );

            if (friendId != null &&
                friendId.isNotEmpty &&
                !acceptedFriendIds.contains(friendId)) {
              acceptedFriendIds.add(friendId);
              pendingOutgoingUserIds.remove(friendId);
              trustedPeople.add(
                TrustedPerson(
                  id: friendId,
                  name: friendName,
                  username: toUsername ?? 'unknown',
                  sharedMemoriesCount: 0,
                  photoUrl: null,
                ),
              );
            }
          }

          if (addedNew) {
            await _persistSeenAcceptedIds(user.uid);
          }
        });
  }

  Future<void> _loadSuggestedPeople(User user) async {
    try {
      final query = await _usersCollection.get();

      final users = query.docs
          .map((doc) {
            final userId = doc.id;
            if (userId == user.uid) return null;
            if (acceptedFriendIds.contains(userId)) return null;
            if (pendingOutgoingUserIds.contains(userId)) return null;
            if (pendingIncomingUserIds.contains(userId)) return null;

            final data = doc.data();
            final username = (data['username'] as String?)?.trim();
            final email = (data['email'] as String?)?.trim();
            final displayName = (data['displayName'] as String?)?.trim();

            final name = displayName?.isNotEmpty == true
                ? displayName!
                : username?.isNotEmpty == true
                ? username!
                : email != null && email.contains('@')
                ? email.split('@').first
                : 'Friend';

            final personUsername = username ?? email ?? 'unknown';
            if (personUsername.isEmpty) return null;

            return TrustedPerson(
              id: userId,
              name: name,
              username: personUsername,
              sharedMemoriesCount: 0,
              photoUrl: null,
            );
          })
          .whereType<TrustedPerson>()
          .toList();

      suggestedPeople.assignAll(users);
    } catch (_) {
      backendError.value = 'Unable to load suggested people';
    }
  }

  Future<void> acceptRequest(String id) async {
    final req = incomingRequests.firstWhereOrNull((r) => r.id == id);
    if (req == null) return;

    try {
      final requestDoc = _friendRequestsCollection.doc(id);
      final snapshot = await requestDoc.get();
      if (snapshot.exists) {
        await requestDoc.update({
          'status': 'accepted',
          'respondedAt': FieldValue.serverTimestamp(),
        });
      }
      incomingRequests.removeWhere((r) => r.id == id);
      pendingIncomingUserIds.remove(req.fromUid);
      trustedPeople.add(
        TrustedPerson(
          id: req.fromUid,
          name: req.name,
          username: req.username,
          sharedMemoriesCount: 0,
          photoUrl: null,
        ),
      );
      if (!acceptedFriendIds.contains(req.fromUid)) {
        acceptedFriendIds.add(req.fromUid);
      }
      _removeSuggestedPerson(req.fromUid);
    } catch (_) {
      backendError.value = 'Unable to accept request';
    }
  }

  Future<void> declineRequest(String id) async {
    try {
      final requestDoc = _friendRequestsCollection.doc(id);
      final snapshot = await requestDoc.get();
      if (snapshot.exists) {
        await requestDoc.update({
          'status': 'declined',
          'respondedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {
      backendError.value = 'Unable to decline request';
    }

    final req = incomingRequests.firstWhereOrNull((r) => r.id == id);
    if (req != null) {
      pendingIncomingUserIds.remove(req.fromUid);
    }
    incomingRequests.removeWhere((r) => r.id == id);
  }

  List<TrustedPerson> get filteredSuggestions {
    final query = searchQuery.value.trim().toLowerCase();
    final filtered = suggestedPeople.where((p) {
      final matchesSearch =
          query.isEmpty ||
          p.username.toLowerCase().contains(query) ||
          p.name.toLowerCase().contains(query);
      final isAvailable = !isFriend(p.id) && !isRequestPending(p.id);
      return matchesSearch && isAvailable;
    }).toList();
    return filtered;
  }

  bool isFriend(String userId) {
    return acceptedFriendIds.contains(userId);
  }

  bool isRequestPending(String userId) {
    return pendingOutgoingUserIds.contains(userId) ||
        pendingIncomingUserIds.contains(userId);
  }

  void _removeSuggestedPerson(String userId) {
    suggestedPeople.removeWhere((p) => p.id == userId);
  }

  Future<void> sendInvite(TrustedPerson person) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar('Failed', 'You must be signed in to add friends.');
      return;
    }

    if (isFriend(person.id)) {
      Get.snackbar(
        'Already connected',
        'You are already connected with ${person.name}.',
      );
      return;
    }

    if (isRequestPending(person.id)) {
      Get.snackbar(
        'Request pending',
        'A request is already pending with ${person.name}.',
      );
      return;
    }

    // ── partner slot paywall ──────────────────────────────────────
    // ── end partner slot paywall ──────────────────────────────────

    try {
      final existingDirect = await _friendRequestsCollection
          .where('fromUid', isEqualTo: user.uid)
          .where('toUid', isEqualTo: person.id)
          .limit(1)
          .get();

      if (existingDirect.docs.isNotEmpty) {
        if (!pendingOutgoingUserIds.contains(person.id)) {
          pendingOutgoingUserIds.add(person.id);
        }
        _removeSuggestedPerson(person.id);
        Get.snackbar(
          'Request pending',
          'You have already sent a request to ${person.name}.',
        );
        return;
      }

      final existingReverse = await _friendRequestsCollection
          .where('fromUid', isEqualTo: person.id)
          .where('toUid', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (existingReverse.docs.isNotEmpty) {
        final status =
            (existingReverse.docs.first.data()['status'] as String?)?.trim() ??
            'pending';
        if (status == 'accepted') {
          if (!acceptedFriendIds.contains(person.id)) {
            acceptedFriendIds.add(person.id);
          }
          trustedPeople.add(person);
          _removeSuggestedPerson(person.id);
          Get.snackbar(
            'Already connected',
            'You are already connected with ${person.name}.',
          );
          return;
        }
        if (status == 'pending') {
          if (!pendingIncomingUserIds.contains(person.id)) {
            pendingIncomingUserIds.add(person.id);
          }
          _removeSuggestedPerson(person.id);
          Get.snackbar(
            'Request pending',
            '${person.name} already sent you a request.',
          );
          return;
        }
      }

      await _friendRequestsCollection.add({
        'fromUid': user.uid,
        'fromName': currentDisplayName.value.isNotEmpty
            ? currentDisplayName.value
            : currentUsername.value,
        'fromUsername': currentUsername.value,
        'toUid': person.id,
        'toName': person.name,
        'toUsername': person.username,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!pendingOutgoingUserIds.contains(person.id)) {
        pendingOutgoingUserIds.add(person.id);
      }
      _removeSuggestedPerson(person.id);
      Get.snackbar('Request sent', 'Invitation sent to ${person.name}');
    } catch (_) {
      backendError.value = 'Unable to send request';
      Get.snackbar('Failed', 'Could not send request. Try again later.');
    }
  }

  Future<void> removeFriend(String friendId, String friendName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final fromMe = await _friendRequestsCollection
          .where('fromUid', isEqualTo: user.uid)
          .where('toUid', isEqualTo: friendId)
          .where('status', isEqualTo: 'accepted')
          .limit(1)
          .get();

      final toMe = await _friendRequestsCollection
          .where('fromUid', isEqualTo: friendId)
          .where('toUid', isEqualTo: user.uid)
          .where('status', isEqualTo: 'accepted')
          .limit(1)
          .get();

      final docs = [...fromMe.docs, ...toMe.docs];
      for (final doc in docs) {
        await _friendRequestsCollection.doc(doc.id).delete();
        _seenAcceptedRequestIds.remove(doc.id);
      }
      await _persistSeenAcceptedIds(user.uid);

      trustedPeople.removeWhere((p) => p.id == friendId);
      acceptedFriendIds.remove(friendId);
      await _loadSuggestedPeople(user);

      Get.snackbar('Removed', 'You are no longer connected with $friendName');
    } catch (_) {
      backendError.value = 'Unable to remove friend';
      Get.snackbar('Failed', 'Could not remove friend. Try again later.');
    }
  }

  @override
  void onClose() {
    _authSub?.cancel();
    super.onClose();
  }
}
