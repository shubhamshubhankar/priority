import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_model.freezed.dart';
part 'task_model.g.dart';

// do = urgent+important, schedule = not-urgent+important,
// delegate = urgent+not-important, eliminate = not-urgent+not-important
enum Quadrant { doNow, schedule, delegate, eliminate }

@freezed
class TaskModel with _$TaskModel {
  const factory TaskModel({
    required String id,
    required String title,
    @Default('') String description,
    @Default(Quadrant.doNow) Quadrant quadrant,
    @Default(false) bool isCompleted,
    DateTime? deadline,
    DateTime? completedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TaskModel;

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);
}
