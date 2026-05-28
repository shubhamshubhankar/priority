import '../models/goal_model.dart';
import '../models/milestone_model.dart';

abstract class GoalsRepository {
  Stream<List<GoalModel>> watchGoals(String uid);
  Future<GoalModel> createGoal(String uid, {
    required String title,
    required GoalHorizon horizon,
    String description,
    DateTime? targetDate,
  });
  Future<void> updateGoal(String uid, GoalModel goal);
  Future<void> deleteGoal(String uid, String goalId);
  Future<void> toggleGoalComplete(String uid, String goalId, bool isCompleted);
  Future<void> updateProgress(String uid, String goalId, int percent);

  Stream<List<MilestoneModel>> watchMilestones(String uid, String goalId);
  Future<MilestoneModel> createMilestone(String uid, String goalId, {required String title, required double position, DateTime? targetDate});
  Future<void> toggleMilestoneComplete(String uid, String goalId, String milestoneId, bool isCompleted);
  Future<void> deleteMilestone(String uid, String goalId, String milestoneId);
}
