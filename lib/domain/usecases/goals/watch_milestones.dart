import '../../../data/models/milestone_model.dart';
import '../../../data/repositories/goals_repository.dart';

class WatchMilestones {
  WatchMilestones(this._repository);
  final GoalsRepository _repository;
  Stream<List<MilestoneModel>> call(String uid, String goalId) =>
      _repository.watchMilestones(uid, goalId);
}
