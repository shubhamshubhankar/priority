import '../../../data/models/task_model.dart';
import '../../../data/repositories/tasks_repository.dart';

class UpdateTask {
  UpdateTask(this._repository);
  final TasksRepository _repository;
  Future<void> call(String uid, TaskModel task) =>
      _repository.updateTask(uid, task);
}
