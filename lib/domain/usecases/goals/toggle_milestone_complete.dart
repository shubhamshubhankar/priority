import '../../../data/repositories/goals_repository.dart';

class ToggleMilestoneComplete {
  ToggleMilestoneComplete(this._repository);
  final GoalsRepository _repository;
  Future<void> call(String uid, String goalId, String milestoneId, bool isCompleted) =>
      _repository.toggleMilestoneComplete(uid, goalId, milestoneId, isCompleted);
}
