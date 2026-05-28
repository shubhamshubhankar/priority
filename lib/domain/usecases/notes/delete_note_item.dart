import '../../../data/repositories/notes_repository.dart';

class DeleteNoteItem {
  DeleteNoteItem(this._repository);
  final NotesRepository _repository;
  Future<void> call(String uid, String noteId, String itemId) =>
      _repository.deleteItem(uid, noteId, itemId);
}
