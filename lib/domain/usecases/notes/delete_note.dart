import '../../../data/repositories/notes_repository.dart';

class DeleteNote {
  DeleteNote(this._repository);
  final NotesRepository _repository;
  Future<void> call(String uid, String noteId) =>
      _repository.deleteNote(uid, noteId);
}
