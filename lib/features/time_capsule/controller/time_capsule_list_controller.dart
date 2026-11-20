import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:lumina/core/routes/services/notification_services.dart';
import 'package:lumina/features/time_capsule/model/time_capsule_model.dart';

class TimeCapsuleListController extends GetxController {
  final capsules = <TimeCapsuleModel>[].obs;
  StreamSubscription? _sub;

  bool get hasUnlockedCapsule => capsules.any((c) => c.isUnlocked);

  @override
  void onInit() {
    super.onInit();
    _listenToCapsules();
  }

  void _listenToCapsules() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _sub = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('time_capsules')
        .orderBy('sealedDate', descending: true)
        .snapshots()
        .listen((snapshot) {
          capsules.value = snapshot.docs
              .map((doc) => TimeCapsuleModel.fromMap(doc.id, doc.data()))
              .toList();
        });
  }

  Future<void> deleteCapsule(String capsuleId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('time_capsules')
        .doc(capsuleId)
        .delete();

    await NotificationService().cancel(capsuleId.hashCode & 0x7fffffff);
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
