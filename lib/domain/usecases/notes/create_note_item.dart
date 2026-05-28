import '../../../data/models/note_item_model.dart';
import '../../../data/repositories/notes_repository.dart';

class CreateNoteItem {
  CreateNoteItem(this._repository);
  final NotesRepository _repository;
  Future<NoteItemModel> call(String uid, String noteId, {required String text, required double position}) =>
      _repository.createItem(uid, noteId, text: text, position: position);
}
