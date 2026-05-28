import 'package:freezed_annotation/freezed_annotation.dart';

part 'subtask_model.freezed.dart';
part 'subtask_model.g.dart';

@freezed
class SubtaskModel with _$SubtaskModel {
  const factory SubtaskModel({
    required String id,
    required String text,
    @Default(false) bool isCompleted,
    @Default(0.0) double position,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SubtaskModel;

  factory SubtaskModel.fromJson(Map<String, dynamic> json) =>
      _$SubtaskModelFromJson(json);
}
