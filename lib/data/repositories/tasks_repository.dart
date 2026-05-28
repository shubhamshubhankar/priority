import '../models/task_model.dart';
import '../models/subtask_model.dart';

abstract class TasksRepository {
  Stream<List<TaskModel>> watchTasks(String uid);
  Future<TaskModel> createTask(String uid, {
    required String title,
    required Quadrant quadrant,
    String description,
    DateTime? deadline,
  });
  Future<void> updateTask(String uid, TaskModel task);
  Future<void> deleteTask(String uid, String taskId);
  Future<void> toggleTaskComplete(String uid, String taskId, bool isCompleted);

  Stream<List<SubtaskModel>> watchSubtasks(String uid, String taskId);
  Future<SubtaskModel> createSubtask(String uid, String taskId, {required String text, required double position});
  Future<void> toggleSubtaskComplete(String uid, String taskId, String subtaskId, bool isCompleted);
  Future<void> deleteSubtask(String uid, String taskId, String subtaskId);
}
