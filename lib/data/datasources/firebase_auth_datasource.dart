import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthDatasource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Created lazily so the constructor never runs on web (it asserts a clientId on web)
  GoogleSignIn? _googleSignIn;
  GoogleSignIn get _mobileSignIn => _googleSignIn ??= GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      // Web: Firebase handles the OAuth popup natively — no client ID config needed
      final provider = GoogleAuthProvider();
      await _auth.signInWithPopup(provider);
    } else {
      // Mobile: use google_sign_in which handles the native account picker
      final googleUser = await _mobileSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign-in aborted');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
    }
    await _upsertUserDocument();
  }

  Future<void> signOut() async {
    if (!kIsWeb) await _mobileSignIn.signOut();
    await _auth.signOut();
  }

  Future<TotpSecret> generateTotpSecret() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final session = await user.multiFactor.getSession();
    return await TotpMultiFactorGenerator.generateSecret(session);
  }

  Future<void> enrollTotp(TotpSecret secret, String otp) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final assertion = await TotpMultiFactorGenerator.getAssertionForEnrollment(
      secret,
      otp,
    );
    await user.multiFactor.enroll(assertion);
    await updateTotpEnrolledFlag(user.uid, true);
  }

  Future<void> verifyTotp(MultiFactorResolver resolver, String otp) async {
    final enrollmentId =
        resolver.hints.whereType<TotpMultiFactorInfo>().first.uid;
    final assertion = await TotpMultiFactorGenerator.getAssertionForSignIn(
      enrollmentId,
      otp,
    );
    await resolver.resolveSignIn(assertion);
    await _upsertUserDocument();
  }

  Future<void> updateTotpEnrolledFlag(String uid, bool enrolled) async {
    await _db.doc('users/$uid').set(
      {'totpEnrolled': enrolled},
      SetOptions(merge: true),
    );
  }

  Future<void> _upsertUserDocument() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final ref = _db.doc('users/${user.uid}');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      await ref.update({'lastSeenAt': FieldValue.serverTimestamp()});
    } else {
      await ref.set({
        'uid': user.uid,
        'email': user.email ?? '',
        'displayName': user.displayName ?? '',
        'photoURL': user.photoURL,
        'totpEnrolled': false,
        'createdAt': FieldValue.serverTimestamp(),
        'lastSeenAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
