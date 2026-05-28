import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/tasks_repository.dart';
import 'matrix_event.dart';
import 'matrix_state.dart';

class MatrixBloc extends Bloc<MatrixEvent, MatrixState> {
  MatrixBloc(this._repository) : super(const MatrixInitial()) {
    on<MatrixSubscribed>(_onSubscribed);
    on<MatrixTasksUpdated>(_onUpdated);
    on<MatrixStreamErrored>(_onStreamError);
    on<MatrixTaskCreated>(_onCreated);
    on<MatrixTaskUpdated>(_onTaskUpdated);
    on<MatrixTaskDeleted>(_onDeleted);
    on<MatrixTaskCompleteToggled>(_onToggled);
  }

  final TasksRepository _repository;
  StreamSubscription? _sub;

  void _onSubscribed(MatrixSubscribed event, Emitter<MatrixState> emit) {
    emit(const MatrixLoading());
    _sub?.cancel();
    _sub = _repository.watchTasks(event.uid).listen(
      (tasks) => add(MatrixTasksUpdated(tasks)),
      // Route errors through add() — emit() cannot be called after handler returns
      onError: (e) => add(MatrixStreamErrored(e.toString())),
    );
  }

  void _onUpdated(MatrixTasksUpdated event, Emitter<MatrixState> emit) {
    emit(MatrixLoaded(event.tasks));
  }

  void _onStreamError(MatrixStreamErrored event, Emitter<MatrixState> emit) {
    emit(MatrixError(event.message));
  }

  Future<void> _onCreated(MatrixTaskCreated event, Emitter<MatrixState> emit) async {
    try {
      await _repository.createTask(
        event.uid,
        title: event.title,
        quadrant: event.quadrant,
        description: event.description,
        deadline: event.deadline,
      );
    } catch (_) {}
  }

  Future<void> _onTaskUpdated(MatrixTaskUpdated event, Emitter<MatrixState> emit) async {
    try {
      await _repository.updateTask(event.uid, event.task);
    } catch (_) {}
  }

  Future<void> _onDeleted(MatrixTaskDeleted event, Emitter<MatrixState> emit) async {
    try {
      await _repository.deleteTask(event.uid, event.taskId);
    } catch (_) {}
  }

  Future<void> _onToggled(MatrixTaskCompleteToggled event, Emitter<MatrixState> emit) async {
    try {
      await _repository.toggleTaskComplete(event.uid, event.taskId, event.isCompleted);
    } catch (_) {}
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
