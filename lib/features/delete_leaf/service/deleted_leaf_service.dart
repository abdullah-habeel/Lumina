import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lumina/features/delete_leaf/model/delete_leaf_model.dart';

class DeletedLeafService {
  final _firestore = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _ref {
    final uid = _uid;
    if (uid == null) throw Exception('No signed-in user.');
    return _firestore.collection('users').doc(uid).collection('deleted_leaves');
  }

  // Save a deleted leaf anchor index
  Future<void> saveDeletedLeaf(int anchorIndex) async {
    await _ref
        .doc(anchorIndex.toString())
        .set(
          DeletedLeaf(
            anchorIndex: anchorIndex,
            deletedAt: DateTime.now(),
          ).toMap(),
        );
  }

  // Permanently remove a deleted leaf (after fall animation)
  Future<void> removeDeletedLeaf(int anchorIndex) async {
    await _ref.doc(anchorIndex.toString()).delete();
  }

  // Stream all deleted leaf anchor indices
  Stream<List<DeletedLeaf>> streamDeletedLeaves() {
    final uid = _uid;
    if (uid == null) return Stream.value([]);

    return _ref.snapshots().map(
      (snap) =>
          snap.docs.map((doc) => DeletedLeaf.fromMap(doc.data())).toList(),
    );
  }
}
