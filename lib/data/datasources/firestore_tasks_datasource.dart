import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/task_model.dart';
import '../models/subtask_model.dart';
import '../../core/constants/firestore_paths.dart';

class FirestoreTasksDatasource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> _tasksCol(String uid) =>
      _db.collection(FirestorePaths.tasks(uid));

  CollectionReference<Map<String, dynamic>> _subtasksCol(String uid, String taskId) =>
      _db.collection(FirestorePaths.subtasks(uid, taskId));

  DateTime? _ts(dynamic v) => v is Timestamp ? v.toDate() : null;

  TaskModel _fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final data = d.data()!;
    return TaskModel.fromJson({
      ...data,
      'id': d.id,
      if (data['createdAt'] is Timestamp) 'createdAt': _ts(data['createdAt'])!.toIso8601String(),
      if (data['updatedAt'] is Timestamp) 'updatedAt': _ts(data['updatedAt'])!.toIso8601String(),
      if (data['deadline'] is Timestamp) 'deadline': _ts(data['deadline'])!.toIso8601String(),
      if (data['completedAt'] is Timestamp) 'completedAt': _ts(data['completedAt'])!.toIso8601String(),
    });
  }

  // Simple query — no composite orderBy. Sort client-side to avoid index requirement.
  Stream<List<TaskModel>> watchTasks(String uid) {
    return _tasksCol(uid).snapshots().map((snap) {
      final tasks = snap.docs.map(_fromDoc).toList();
      tasks.sort((a, b) {
        if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
        return b.updatedAt.compareTo(a.updatedAt);
      });
      return tasks;
    });
  }

  Future<TaskModel> createTask(
    String uid, {
    required String title,
    required Quadrant quadrant,
    String description = '',
    DateTime? deadline,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    await _tasksCol(uid).doc(id).set({
      'title': title,
      'description': description,
      'quadrant': quadrant.name,
      'isCompleted': false,
      'deadline': deadline != null ? Timestamp.fromDate(deadline) : null,
      'completedAt': null,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });
    return TaskModel(
      id: id, title: title, description: description,
      quadrant: quadrant, deadline: deadline,
      createdAt: now, updatedAt: now,
    );
  }

  Future<void> updateTask(String uid, TaskModel task) async {
    await _tasksCol(uid).doc(task.id).update({
      'title': task.title,
      'description': task.description,
      'quadrant': task.quadrant.name,
      'deadline': task.deadline != null ? Timestamp.fromDate(task.deadline!) : null,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> deleteTask(String uid, String taskId) async {
    final subtasks = await _subtasksCol(uid, taskId).get();
    final batch = _db.batch();
    for (final doc in subtasks.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_tasksCol(uid).doc(taskId));
    await batch.commit();
  }

  Future<void> toggleTaskComplete(String uid, String taskId, bool isCompleted) async {
    await _tasksCol(uid).doc(taskId).update({
      'isCompleted': isCompleted,
      'completedAt': isCompleted ? Timestamp.fromDate(DateTime.now()) : null,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Stream<List<SubtaskModel>> watchSubtasks(String uid, String taskId) {
    return _subtasksCol(uid, taskId).snapshots().map((snap) {
      final subtasks = snap.docs.map((d) {
        final data = d.data();
        return SubtaskModel.fromJson({
          ...data,
          'id': d.id,
          if (data['createdAt'] is Timestamp) 'createdAt': _ts(data['createdAt'])!.toIso8601String(),
          if (data['updatedAt'] is Timestamp) 'updatedAt': _ts(data['updatedAt'])!.toIso8601String(),
        });
      }).toList();
      subtasks.sort((a, b) {
        if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
        return a.position.compareTo(b.position);
      });
      return subtasks;
    });
  }

  Future<SubtaskModel> createSubtask(
    String uid, String taskId, {
    required String text,
    required double position,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    await _subtasksCol(uid, taskId).doc(id).set({
      'text': text,
      'isCompleted': false,
      'position': position,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });
    return SubtaskModel(id: id, text: text, position: position, createdAt: now, updatedAt: now);
  }

  Future<void> toggleSubtaskComplete(
    String uid, String taskId, String subtaskId, bool isCompleted,
  ) async {
    await _subtasksCol(uid, taskId).doc(subtaskId).update({
      'isCompleted': isCompleted,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> deleteSubtask(String uid, String taskId, String subtaskId) async {
    await _subtasksCol(uid, taskId).doc(subtaskId).delete();
  }
}
