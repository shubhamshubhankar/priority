import '../models/note_model.dart';
import '../models/note_item_model.dart';

abstract class NotesRepository {
  Stream<List<NoteModel>> watchNotes(String uid);
  Future<NoteModel> createNote(String uid, {required String title, String? color});
  Future<void> updateNote(String uid, NoteModel note);
  Future<void> deleteNote(String uid, String noteId);
  Future<void> togglePin(String uid, String noteId, bool isPinned);

  Stream<List<NoteItemModel>> watchItems(String uid, String noteId);
  Future<NoteItemModel> createItem(String uid, String noteId, {required String text, required double position});
  Future<void> updateItem(String uid, String noteId, NoteItemModel item);
  Future<void> toggleItemChecked(String uid, String noteId, String itemId, bool isChecked);
  Future<void> deleteItem(String uid, String noteId, String itemId);
}
