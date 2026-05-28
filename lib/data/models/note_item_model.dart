import 'package:freezed_annotation/freezed_annotation.dart';

part 'note_item_model.freezed.dart';
part 'note_item_model.g.dart';

@freezed
class NoteItemModel with _$NoteItemModel {
  const factory NoteItemModel({
    required String id,
    required String text,
    @Default(false) bool isChecked,
    @Default(0.0) double position,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _NoteItemModel;

  factory NoteItemModel.fromJson(Map<String, dynamic> json) =>
      _$NoteItemModelFromJson(json);
}
