import '../../../data/models/note_item_model.dart';
import '../../../data/repositories/notes_repository.dart';

class WatchNoteItems {
  WatchNoteItems(this._repository);
  final NotesRepository _repository;
  Stream<List<NoteItemModel>> call(String uid, String noteId) =>
      _repository.watchItems(uid, noteId);
}
