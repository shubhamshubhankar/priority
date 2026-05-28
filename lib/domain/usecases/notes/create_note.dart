import '../../../data/models/note_model.dart';
import '../../../data/repositories/notes_repository.dart';

class CreateNote {
  CreateNote(this._repository);
  final NotesRepository _repository;
  Future<NoteModel> call(String uid, {required String title, String? color}) =>
      _repository.createNote(uid, title: title, color: color);
}
