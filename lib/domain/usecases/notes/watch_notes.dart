import '../../../data/models/note_model.dart';
import '../../../data/repositories/notes_repository.dart';

class WatchNotes {
  WatchNotes(this._repository);
  final NotesRepository _repository;
  Stream<List<NoteModel>> call(String uid) => _repository.watchNotes(uid);
}
