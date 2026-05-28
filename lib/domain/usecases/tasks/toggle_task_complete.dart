import '../../../data/repositories/tasks_repository.dart';

class ToggleTaskComplete {
  ToggleTaskComplete(this._repository);
  final TasksRepository _repository;
  Future<void> call(String uid, String taskId, bool isCompleted) =>
      _repository.toggleTaskComplete(uid, taskId, isCompleted);
}
