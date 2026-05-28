import 'package:equatable/equatable.dart';

import '../../../data/models/goal_model.dart';

abstract class GoalsEvent extends Equatable {
  const GoalsEvent();
  @override
  List<Object?> get props => [];
}

class GoalsSubscribed extends GoalsEvent {
  const GoalsSubscribed(this.uid);
  final String uid;
  @override
  List<Object?> get props => [uid];
}

class GoalsUpdated extends GoalsEvent {
  const GoalsUpdated(this.goals);
  final List<GoalModel> goals;
  @override
  List<Object?> get props => [goals];
}

class GoalCreated extends GoalsEvent {
  const GoalCreated({required this.uid, required this.title, required this.horizon, this.targetDate});
  final String uid;
  final String title;
  final GoalHorizon horizon;
  final DateTime? targetDate;
  @override
  List<Object?> get props => [uid, title, horizon, targetDate];
}

class GoalUpdated extends GoalsEvent {
  const GoalUpdated({required this.uid, required this.goal});
  final String uid;
  final GoalModel goal;
  @override
  List<Object?> get props => [uid, goal];
}

class GoalDeleted extends GoalsEvent {
  const GoalDeleted({required this.uid, required this.goalId});
  final String uid;
  final String goalId;
  @override
  List<Object?> get props => [uid, goalId];
}

class GoalCompleteToggled extends GoalsEvent {
  const GoalCompleteToggled({required this.uid, required this.goalId, required this.isCompleted});
  final String uid;
  final String goalId;
  final bool isCompleted;
  @override
  List<Object?> get props => [uid, goalId, isCompleted];
}

class GoalsStreamErrored extends GoalsEvent {
  const GoalsStreamErrored(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
