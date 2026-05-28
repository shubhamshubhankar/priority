import '../../datasources/firestore_goals_datasource.dart';
import '../../models/goal_model.dart';
import '../../models/milestone_model.dart';
import '../goals_repository.dart';

class GoalsRepositoryImpl implements GoalsRepository {
  GoalsRepositoryImpl(this._datasource);

  final FirestoreGoalsDatasource _datasource;

  @override
  Stream<List<GoalModel>> watchGoals(String uid) =>
      _datasource.watchGoals(uid);

  @override
  Future<GoalModel> createGoal(String uid, {
    required String title,
    required GoalHorizon horizon,
    String description = '',
    DateTime? targetDate,
  }) =>
      _datasource.createGoal(uid, title: title, horizon: horizon, description: description, targetDate: targetDate);

  @override
  Future<void> updateGoal(String uid, GoalModel goal) =>
      _datasource.updateGoal(uid, goal);

  @override
  Future<void> deleteGoal(String uid, String goalId) =>
      _datasource.deleteGoal(uid, goalId);

  @override
  Future<void> toggleGoalComplete(String uid, String goalId, bool isCompleted) =>
      _datasource.toggleGoalComplete(uid, goalId, isCompleted);

  @override
  Future<void> updateProgress(String uid, String goalId, int percent) =>
      _datasource.updateProgress(uid, goalId, percent);

  @override
  Stream<List<MilestoneModel>> watchMilestones(String uid, String goalId) =>
      _datasource.watchMilestones(uid, goalId);

  @override
  Future<MilestoneModel> createMilestone(String uid, String goalId, {required String title, required double position, DateTime? targetDate}) =>
      _datasource.createMilestone(uid, goalId, title: title, position: position, targetDate: targetDate);

  @override
  Future<void> toggleMilestoneComplete(String uid, String goalId, String milestoneId, bool isCompleted) =>
      _datasource.toggleMilestoneComplete(uid, goalId, milestoneId, isCompleted);

  @override
  Future<void> deleteMilestone(String uid, String goalId, String milestoneId) =>
      _datasource.deleteMilestone(uid, goalId, milestoneId);
}
