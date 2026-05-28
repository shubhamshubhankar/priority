import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/goals_repository.dart';
import 'goals_event.dart';
import 'goals_state.dart';

class GoalsBloc extends Bloc<GoalsEvent, GoalsState> {
  GoalsBloc(this._repository) : super(const GoalsInitial()) {
    on<GoalsSubscribed>(_onSubscribed);
    on<GoalsUpdated>(_onUpdated);
    on<GoalsStreamErrored>(_onStreamError);
    on<GoalCreated>(_onCreated);
    on<GoalUpdated>(_onGoalUpdated);
    on<GoalDeleted>(_onDeleted);
    on<GoalCompleteToggled>(_onToggled);
  }

  final GoalsRepository _repository;
  StreamSubscription? _sub;

  void _onSubscribed(GoalsSubscribed event, Emitter<GoalsState> emit) {
    emit(const GoalsLoading());
    _sub?.cancel();
    _sub = _repository.watchGoals(event.uid).listen(
      (goals) => add(GoalsUpdated(goals)),
      onError: (e) => add(GoalsStreamErrored(e.toString())),
    );
  }

  void _onUpdated(GoalsUpdated event, Emitter<GoalsState> emit) {
    emit(GoalsLoaded(event.goals));
  }

  void _onStreamError(GoalsStreamErrored event, Emitter<GoalsState> emit) {
    emit(GoalsError(event.message));
  }

  Future<void> _onCreated(GoalCreated event, Emitter<GoalsState> emit) async {
    try {
      await _repository.createGoal(event.uid, title: event.title, horizon: event.horizon, targetDate: event.targetDate);
    } catch (_) {}
  }

  Future<void> _onGoalUpdated(GoalUpdated event, Emitter<GoalsState> emit) async {
    try {
      await _repository.updateGoal(event.uid, event.goal);
    } catch (_) {}
  }

  Future<void> _onDeleted(GoalDeleted event, Emitter<GoalsState> emit) async {
    try {
      await _repository.deleteGoal(event.uid, event.goalId);
    } catch (_) {}
  }

  Future<void> _onToggled(GoalCompleteToggled event, Emitter<GoalsState> emit) async {
    try {
      await _repository.toggleGoalComplete(event.uid, event.goalId, event.isCompleted);
    } catch (_) {}
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
