import '../../../data/models/subtask_model.dart';
import '../../../data/repositories/tasks_repository.dart';

class CreateSubtask {
  CreateSubtask(this._repository);
  final TasksRepository _repository;
  Future<SubtaskModel> call(String uid, String taskId, {required String text, required double position}) =>
      _repository.createSubtask(uid, taskId, text: text, position: position);
}
