import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal_model.freezed.dart';
part 'goal_model.g.dart';

enum GoalHorizon { shortTerm, longTerm }

@freezed
class GoalModel with _$GoalModel {
  const factory GoalModel({
    required String id,
    required String title,
    @Default('') String description,
    @Default(GoalHorizon.shortTerm) GoalHorizon horizon,
    DateTime? targetDate,
    @Default(false) bool isCompleted,
    DateTime? completedAt,
    @Default(0) int progressPercent,
    String? color,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _GoalModel;

  factory GoalModel.fromJson(Map<String, dynamic> json) =>
      _$GoalModelFromJson(json);
}
