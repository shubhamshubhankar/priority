import '../../../data/models/goal_model.dart';
import '../../../data/repositories/goals_repository.dart';

class WatchGoals {
  WatchGoals(this._repository);
  final GoalsRepository _repository;
  Stream<List<GoalModel>> call(String uid) => _repository.watchGoals(uid);
}
