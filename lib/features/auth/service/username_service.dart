import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsernameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> isUsernameAvailable(String username) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('usernameLower', isEqualTo: username.toLowerCase())
          .limit(1)
          .get();

      return query.docs.isEmpty;
    } catch (_) {
      return true;
    }
  }

  Future<void> saveUsername(String username) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('No authenticated user');

    await _firestore.collection('users').doc(uid).set({
      'username': username,
      'usernameLower': username.toLowerCase(),
      'uid': uid,
      'email': _auth.currentUser?.email,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Username is now set — cache it so future launches skip Firestore.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('username_setup_done_$uid', true);
  }

  /// Call this right after any successful login (email or Google)
  /// to decide whether the user needs to go through username setup.
  Future<bool> needsUsernameSetup(String uid) async {
    final prefs = await SharedPreferences.getInstance();

    // Cache hit — skip Firestore entirely.
    final cached = prefs.getBool('username_setup_done_$uid');
    if (cached == true) return false;

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return true;
      final data = doc.data();
      final needsSetup = data == null || data['username'] == null;

      if (!needsSetup) {
        await prefs.setBool('username_setup_done_$uid', true);
      }

      return needsSetup;
    } catch (_) {
      return true;
    }
  }
}