import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/goal_model.dart';
import '../models/milestone_model.dart';
import '../../core/constants/firestore_paths.dart';

class FirestoreGoalsDatasource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> _goalsCol(String uid) =>
      _db.collection(FirestorePaths.goals(uid));

  CollectionReference<Map<String, dynamic>> _milestonesCol(String uid, String goalId) =>
      _db.collection(FirestorePaths.milestones(uid, goalId));

  DateTime? _ts(dynamic v) => v is Timestamp ? v.toDate() : null;

  GoalModel _fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final data = d.data()!;
    return GoalModel.fromJson({
      ...data,
      'id': d.id,
      if (data['createdAt'] is Timestamp) 'createdAt': _ts(data['createdAt'])!.toIso8601String(),
      if (data['updatedAt'] is Timestamp) 'updatedAt': _ts(data['updatedAt'])!.toIso8601String(),
      if (data['targetDate'] is Timestamp) 'targetDate': _ts(data['targetDate'])!.toIso8601String(),
      if (data['completedAt'] is Timestamp) 'completedAt': _ts(data['completedAt'])!.toIso8601String(),
    });
  }

  // Simple query — sort client-side to avoid composite index requirement.
  Stream<List<GoalModel>> watchGoals(String uid) {
    return _goalsCol(uid).snapshots().map((snap) {
      final goals = snap.docs.map(_fromDoc).toList();
      goals.sort((a, b) {
        if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
        return b.updatedAt.compareTo(a.updatedAt);
      });
      return goals;
    });
  }

  Future<GoalModel> createGoal(
    String uid, {
    required String title,
    required GoalHorizon horizon,
    String description = '',
    DateTime? targetDate,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    await _goalsCol(uid).doc(id).set({
      'title': title,
      'description': description,
      'horizon': horizon.name,
      'targetDate': targetDate != null ? Timestamp.fromDate(targetDate) : null,
      'isCompleted': false,
      'completedAt': null,
      'progressPercent': 0,
      'color': null,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });
    return GoalModel(id: id, title: title, description: description, horizon: horizon, targetDate: targetDate, createdAt: now, updatedAt: now);
  }

  Future<void> updateGoal(String uid, GoalModel goal) async {
    await _goalsCol(uid).doc(goal.id).update({
      'title': goal.title,
      'description': goal.description,
      'horizon': goal.horizon.name,
      'targetDate': goal.targetDate != null ? Timestamp.fromDate(goal.targetDate!) : null,
      'color': goal.color,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> deleteGoal(String uid, String goalId) async {
    final milestones = await _milestonesCol(uid, goalId).get();
    final batch = _db.batch();
    for (final doc in milestones.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_goalsCol(uid).doc(goalId));
    await batch.commit();
  }

  Future<void> toggleGoalComplete(String uid, String goalId, bool isCompleted) async {
    await _goalsCol(uid).doc(goalId).update({
      'isCompleted': isCompleted,
      'completedAt': isCompleted ? Timestamp.fromDate(DateTime.now()) : null,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> updateProgress(String uid, String goalId, int percent) async {
    await _goalsCol(uid).doc(goalId).update({
      'progressPercent': percent,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Stream<List<MilestoneModel>> watchMilestones(String uid, String goalId) {
    return _milestonesCol(uid, goalId).snapshots().map((snap) {
      final milestones = snap.docs.map((d) {
        final data = d.data();
        return MilestoneModel.fromJson({
          ...data,
          'id': d.id,
          if (data['createdAt'] is Timestamp) 'createdAt': _ts(data['createdAt'])!.toIso8601String(),
          if (data['updatedAt'] is Timestamp) 'updatedAt': _ts(data['updatedAt'])!.toIso8601String(),
          if (data['targetDate'] is Timestamp) 'targetDate': _ts(data['targetDate'])!.toIso8601String(),
          if (data['completedAt'] is Timestamp) 'completedAt': _ts(data['completedAt'])!.toIso8601String(),
        });
      }).toList();
      milestones.sort((a, b) {
        if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
        return a.position.compareTo(b.position);
      });
      return milestones;
    });
  }

  Future<MilestoneModel> createMilestone(
    String uid, String goalId, {
    required String title,
    required double position,
    DateTime? targetDate,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    await _milestonesCol(uid, goalId).doc(id).set({
      'title': title,
      'targetDate': targetDate != null ? Timestamp.fromDate(targetDate) : null,
      'isCompleted': false,
      'completedAt': null,
      'position': position,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });
    return MilestoneModel(id: id, title: title, targetDate: targetDate, position: position, createdAt: now, updatedAt: now);
  }

  Future<void> toggleMilestoneComplete(
    String uid, String goalId, String milestoneId, bool isCompleted,
  ) async {
    await _milestonesCol(uid, goalId).doc(milestoneId).update({
      'isCompleted': isCompleted,
      'completedAt': isCompleted ? Timestamp.fromDate(DateTime.now()) : null,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> deleteMilestone(String uid, String goalId, String milestoneId) async {
    await _milestonesCol(uid, goalId).doc(milestoneId).delete();
  }
}
