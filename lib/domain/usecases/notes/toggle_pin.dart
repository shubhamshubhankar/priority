import '../../../data/repositories/notes_repository.dart';

class TogglePin {
  TogglePin(this._repository);
  final NotesRepository _repository;
  Future<void> call(String uid, String noteId, bool isPinned) =>
      _repository.togglePin(uid, noteId, isPinned);
}
