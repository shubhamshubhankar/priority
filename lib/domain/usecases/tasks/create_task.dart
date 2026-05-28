import '../../../data/models/task_model.dart';
import '../../../data/repositories/tasks_repository.dart';

class CreateTask {
  CreateTask(this._repository);
  final TasksRepository _repository;
  Future<TaskModel> call(String uid, {
    required String title,
    required Quadrant quadrant,
    String description = '',
    DateTime? deadline,
  }) =>
      _repository.createTask(uid, title: title, quadrant: quadrant, description: description, deadline: deadline);
}
