import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<void> signInWithGoogle();
  Future<void> signOut();
  Future<TotpSecret> generateTotpSecret();
  Future<void> enrollTotp(TotpSecret secret, String otp);
  Future<void> verifyTotp(MultiFactorResolver resolver, String otp);
  Future<void> updateTotpEnrolledFlag(String uid, bool enrolled);
  Stream<User?> get authStateChanges;
}
