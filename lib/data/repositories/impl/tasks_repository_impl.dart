import '../../datasources/firestore_tasks_datasource.dart';
import '../../models/task_model.dart';
import '../../models/subtask_model.dart';
import '../tasks_repository.dart';

class TasksRepositoryImpl implements TasksRepository {
  TasksRepositoryImpl(this._datasource);

  final FirestoreTasksDatasource _datasource;

  @override
  Stream<List<TaskModel>> watchTasks(String uid) =>
      _datasource.watchTasks(uid);

  @override
  Future<TaskModel> createTask(String uid, {
    required String title,
    required Quadrant quadrant,
    String description = '',
    DateTime? deadline,
  }) =>
      _datasource.createTask(uid, title: title, quadrant: quadrant, description: description, deadline: deadline);

  @override
  Future<void> updateTask(String uid, TaskModel task) =>
      _datasource.updateTask(uid, task);

  @override
  Future<void> deleteTask(String uid, String taskId) =>
      _datasource.deleteTask(uid, taskId);

  @override
  Future<void> toggleTaskComplete(String uid, String taskId, bool isCompleted) =>
      _datasource.toggleTaskComplete(uid, taskId, isCompleted);

  @override
  Stream<List<SubtaskModel>> watchSubtasks(String uid, String taskId) =>
      _datasource.watchSubtasks(uid, taskId);

  @override
  Future<SubtaskModel> createSubtask(String uid, String taskId, {required String text, required double position}) =>
      _datasource.createSubtask(uid, taskId, text: text, position: position);

  @override
  Future<void> toggleSubtaskComplete(String uid, String taskId, String subtaskId, bool isCompleted) =>
      _datasource.toggleSubtaskComplete(uid, taskId, subtaskId, isCompleted);

  @override
  Future<void> deleteSubtask(String uid, String taskId, String subtaskId) =>
      _datasource.deleteSubtask(uid, taskId, subtaskId);
}
