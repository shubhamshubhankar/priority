import 'package:freezed_annotation/freezed_annotation.dart';

part 'milestone_model.freezed.dart';
part 'milestone_model.g.dart';

@freezed
class MilestoneModel with _$MilestoneModel {
  const factory MilestoneModel({
    required String id,
    required String title,
    DateTime? targetDate,
    @Default(false) bool isCompleted,
    DateTime? completedAt,
    @Default(0.0) double position,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _MilestoneModel;

  factory MilestoneModel.fromJson(Map<String, dynamic> json) =>
      _$MilestoneModelFromJson(json);
}
