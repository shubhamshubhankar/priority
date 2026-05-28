import '../../../data/repositories/goals_repository.dart';

class DeleteGoal {
  DeleteGoal(this._repository);
  final GoalsRepository _repository;
  Future<void> call(String uid, String goalId) =>
      _repository.deleteGoal(uid, goalId);
}
