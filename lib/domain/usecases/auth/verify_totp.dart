import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/repositories/auth_repository.dart';

class VerifyTotp {
  VerifyTotp(this._repository);
  final AuthRepository _repository;

  Future<void> call(MultiFactorResolver resolver, String otp) =>
      _repository.verifyTotp(resolver, otp);
}
