import '../../../data/repositories/tasks_repository.dart';

class DeleteTask {
  DeleteTask(this._repository);
  final TasksRepository _repository;
  Future<void> call(String uid, String taskId) =>
      _repository.deleteTask(uid, taskId);
}
