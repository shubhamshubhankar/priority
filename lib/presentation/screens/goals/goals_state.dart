import 'package:equatable/equatable.dart';

import '../../../data/models/goal_model.dart';

abstract class GoalsState extends Equatable {
  const GoalsState();
  @override
  List<Object?> get props => [];
}

class GoalsInitial extends GoalsState {
  const GoalsInitial();
}

class GoalsLoading extends GoalsState {
  const GoalsLoading();
}

class GoalsLoaded extends GoalsState {
  const GoalsLoaded(this.goals);
  final List<GoalModel> goals;

  List<GoalModel> get shortTerm => goals.where((g) => g.horizon == GoalHorizon.shortTerm).toList();
  List<GoalModel> get longTerm  => goals.where((g) => g.horizon == GoalHorizon.longTerm).toList();

  @override
  List<Object?> get props => [goals];
}

class GoalsError extends GoalsState {
  const GoalsError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
