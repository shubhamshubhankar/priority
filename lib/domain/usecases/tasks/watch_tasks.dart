import '../../../data/models/task_model.dart';
import '../../../data/repositories/tasks_repository.dart';

class WatchTasks {
  WatchTasks(this._repository);
  final TasksRepository _repository;
  Stream<List<TaskModel>> call(String uid) => _repository.watchTasks(uid);
}
