import 'package:firebase_auth/firebase_auth.dart';

import '../../datasources/firebase_auth_datasource.dart';
import '../auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._datasource);

  final FirebaseAuthDatasource _datasource;

  @override
  Stream<User?> get authStateChanges => _datasource.authStateChanges;

  @override
  Future<void> signInWithGoogle() => _datasource.signInWithGoogle();

  @override
  Future<void> signOut() => _datasource.signOut();

  @override
  Future<TotpSecret> generateTotpSecret() => _datasource.generateTotpSecret();

  @override
  Future<void> enrollTotp(TotpSecret secret, String otp) =>
      _datasource.enrollTotp(secret, otp);

  @override
  Future<void> verifyTotp(MultiFactorResolver resolver, String otp) =>
      _datasource.verifyTotp(resolver, otp);

  @override
  Future<void> updateTotpEnrolledFlag(String uid, bool enrolled) =>
      _datasource.updateTotpEnrolledFlag(uid, enrolled);
}
