import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/repositories/auth_repository.dart';

class EnrollTotp {
  EnrollTotp(this._repository);
  final AuthRepository _repository;

  Future<TotpSecret> generateSecret() => _repository.generateTotpSecret();

  Future<void> enroll(TotpSecret secret, String otp) =>
      _repository.enrollTotp(secret, otp);
}
