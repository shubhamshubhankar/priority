import '../../../data/models/note_model.dart';
import '../../../data/repositories/notes_repository.dart';

class UpdateNote {
  UpdateNote(this._repository);
  final NotesRepository _repository;
  Future<void> call(String uid, NoteModel note) =>
      _repository.updateNote(uid, note);
}
