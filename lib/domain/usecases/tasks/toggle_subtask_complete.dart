import '../../../data/repositories/tasks_repository.dart';

class ToggleSubtaskComplete {
  ToggleSubtaskComplete(this._repository);
  final TasksRepository _repository;
  Future<void> call(String uid, String taskId, String subtaskId, bool isCompleted) =>
      _repository.toggleSubtaskComplete(uid, taskId, subtaskId, isCompleted);
}
