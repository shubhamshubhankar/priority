import '../../../data/repositories/tasks_repository.dart';

class DeleteSubtask {
  DeleteSubtask(this._repository);
  final TasksRepository _repository;
  Future<void> call(String uid, String taskId, String subtaskId) =>
      _repository.deleteSubtask(uid, taskId, subtaskId);
}
