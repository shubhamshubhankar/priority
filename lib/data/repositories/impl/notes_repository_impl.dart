import '../../datasources/firestore_notes_datasource.dart';
import '../../models/note_model.dart';
import '../../models/note_item_model.dart';
import '../notes_repository.dart';

class NotesRepositoryImpl implements NotesRepository {
  NotesRepositoryImpl(this._datasource);

  final FirestoreNotesDatasource _datasource;

  @override
  Stream<List<NoteModel>> watchNotes(String uid) =>
      _datasource.watchNotes(uid);

  @override
  Future<NoteModel> createNote(String uid, {required String title, String? color}) =>
      _datasource.createNote(uid, title: title, color: color);

  @override
  Future<void> updateNote(String uid, NoteModel note) =>
      _datasource.updateNote(uid, note);

  @override
  Future<void> deleteNote(String uid, String noteId) =>
      _datasource.deleteNote(uid, noteId);

  @override
  Future<void> togglePin(String uid, String noteId, bool isPinned) =>
      _datasource.togglePin(uid, noteId, isPinned);

  @override
  Stream<List<NoteItemModel>> watchItems(String uid, String noteId) =>
      _datasource.watchItems(uid, noteId);

  @override
  Future<NoteItemModel> createItem(String uid, String noteId, {required String text, required double position}) =>
      _datasource.createItem(uid, noteId, text: text, position: position);

  @override
  Future<void> updateItem(String uid, String noteId, NoteItemModel item) =>
      _datasource.updateItem(uid, noteId, item);

  @override
  Future<void> toggleItemChecked(String uid, String noteId, String itemId, bool isChecked) =>
      _datasource.toggleItemChecked(uid, noteId, itemId, isChecked);

  @override
  Future<void> deleteItem(String uid, String noteId, String itemId) =>
      _datasource.deleteItem(uid, noteId, itemId);
}
