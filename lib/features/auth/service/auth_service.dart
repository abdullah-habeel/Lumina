import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();

  static Future<bool> login({
    required String email,
    required String password,
  }) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return true;
  }

  static Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final credentials = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    await credentials.user?.updateDisplayName(name);
    await credentials.user?.reload();
    return true;
  }

  static Future<void> forgotPassword(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  static Future<bool> signInWithGoogle() async {
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) return false;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
    return true;
  } catch (e) {
    print('Google Sign-In error: $e');
    return false;
  }
}
}