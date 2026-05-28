import '../../../data/models/goal_model.dart';
import '../../../data/repositories/goals_repository.dart';

class CreateGoal {
  CreateGoal(this._repository);
  final GoalsRepository _repository;
  Future<GoalModel> call(String uid, {
    required String title,
    required GoalHorizon horizon,
    String description = '',
    DateTime? targetDate,
  }) =>
      _repository.createGoal(uid, title: title, horizon: horizon, description: description, targetDate: targetDate);
}
