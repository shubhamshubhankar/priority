import '../../../data/repositories/notes_repository.dart';

class ToggleItemChecked {
  ToggleItemChecked(this._repository);
  final NotesRepository _repository;
  Future<void> call(String uid, String noteId, String itemId, bool isChecked) =>
      _repository.toggleItemChecked(uid, noteId, itemId, isChecked);
}
