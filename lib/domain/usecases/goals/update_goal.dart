import '../../../data/models/goal_model.dart';
import '../../../data/repositories/goals_repository.dart';

class UpdateGoal {
  UpdateGoal(this._repository);
  final GoalsRepository _repository;
  Future<void> call(String uid, GoalModel goal) =>
      _repository.updateGoal(uid, goal);
}
