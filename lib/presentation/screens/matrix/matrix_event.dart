import 'package:equatable/equatable.dart';

import '../../../data/models/task_model.dart';

abstract class MatrixEvent extends Equatable {
  const MatrixEvent();
  @override
  List<Object?> get props => [];
}

class MatrixSubscribed extends MatrixEvent {
  const MatrixSubscribed(this.uid);
  final String uid;
  @override
  List<Object?> get props => [uid];
}

class MatrixTasksUpdated extends MatrixEvent {
  const MatrixTasksUpdated(this.tasks);
  final List<TaskModel> tasks;
  @override
  List<Object?> get props => [tasks];
}

class MatrixTaskCreated extends MatrixEvent {
  const MatrixTaskCreated({
    required this.uid,
    required this.title,
    required this.quadrant,
    this.description = '',
    this.deadline,
  });
  final String uid;
  final String title;
  final Quadrant quadrant;
  final String description;
  final DateTime? deadline;
  @override
  List<Object?> get props => [uid, title, quadrant, deadline];
}

class MatrixTaskUpdated extends MatrixEvent {
  const MatrixTaskUpdated({required this.uid, required this.task});
  final String uid;
  final TaskModel task;
  @override
  List<Object?> get props => [uid, task];
}

class MatrixTaskDeleted extends MatrixEvent {
  const MatrixTaskDeleted({required this.uid, required this.taskId});
  final String uid;
  final String taskId;
  @override
  List<Object?> get props => [uid, taskId];
}

class MatrixTaskCompleteToggled extends MatrixEvent {
  const MatrixTaskCompleteToggled({required this.uid, required this.taskId, required this.isCompleted});
  final String uid;
  final String taskId;
  final bool isCompleted;
  @override
  List<Object?> get props => [uid, taskId, isCompleted];
}

class MatrixStreamErrored extends MatrixEvent {
  const MatrixStreamErrored(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
