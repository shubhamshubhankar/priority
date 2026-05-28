import 'package:equatable/equatable.dart';

import '../../../data/models/task_model.dart';

abstract class MatrixState extends Equatable {
  const MatrixState();
  @override
  List<Object?> get props => [];
}

class MatrixInitial extends MatrixState {
  const MatrixInitial();
}

class MatrixLoading extends MatrixState {
  const MatrixLoading();
}

class MatrixLoaded extends MatrixState {
  const MatrixLoaded(this.tasks);
  final List<TaskModel> tasks;

  List<TaskModel> forQuadrant(Quadrant q) {
    final list = tasks.where((t) => t.quadrant == q).toList();
    list.sort((a, b) {
      if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return list;
  }

  @override
  List<Object?> get props => [tasks];
}

class MatrixError extends MatrixState {
  const MatrixError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
