import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/note_model.dart';
import '../models/note_item_model.dart';
import '../../core/constants/firestore_paths.dart';

class FirestoreNotesDatasource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> _notesCol(String uid) =>
      _db.collection(FirestorePaths.notes(uid));

  CollectionReference<Map<String, dynamic>> _itemsCol(String uid, String noteId) =>
      _db.collection(FirestorePaths.noteItems(uid, noteId));

  DateTime? _ts(dynamic v) => v is Timestamp ? v.toDate() : null;

  NoteModel _fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final data = d.data()!;
    return NoteModel.fromJson({
      ...data,
      'id': d.id,
      if (data['createdAt'] is Timestamp) 'createdAt': _ts(data['createdAt'])!.toIso8601String(),
      if (data['updatedAt'] is Timestamp) 'updatedAt': _ts(data['updatedAt'])!.toIso8601String(),
    });
  }

  // Simple where-only query — sorting done client-side to avoid composite indexes.
  Stream<List<NoteModel>> watchNotes(String uid) {
    return _notesCol(uid)
        .where('isArchived', isEqualTo: false)
        .snapshots()
        .map((snap) {
      final notes = snap.docs.map(_fromDoc).toList();
      // Pinned first, then by most-recently-updated
      notes.sort((a, b) {
        if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });
      return notes;
    });
  }

  Future<NoteModel> createNote(String uid, {required String title, String? color}) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    await _notesCol(uid).doc(id).set({
      'title': title,
      'isPinned': false,
      'color': color,
      'isArchived': false,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });
    return NoteModel(id: id, title: title, color: color, createdAt: now, updatedAt: now);
  }

  Future<void> updateNote(String uid, NoteModel note) async {
    await _notesCol(uid).doc(note.id).update({
      'title': note.title,
      'isPinned': note.isPinned,
      'color': note.color,
      'isArchived': note.isArchived,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> deleteNote(String uid, String noteId) async {
    final items = await _itemsCol(uid, noteId).get();
    final batch = _db.batch();
    for (final doc in items.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_notesCol(uid).doc(noteId));
    await batch.commit();
  }

  Future<void> togglePin(String uid, String noteId, bool isPinned) async {
    await _notesCol(uid).doc(noteId).update({
      'isPinned': isPinned,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Stream<List<NoteItemModel>> watchItems(String uid, String noteId) {
    return _itemsCol(uid, noteId).snapshots().map((snap) {
      final items = snap.docs.map((d) {
        final data = d.data();
        return NoteItemModel.fromJson({
          ...data,
          'id': d.id,
          if (data['createdAt'] is Timestamp) 'createdAt': _ts(data['createdAt'])!.toIso8601String(),
          if (data['updatedAt'] is Timestamp) 'updatedAt': _ts(data['updatedAt'])!.toIso8601String(),
        });
      }).toList();
      // Unchecked items first, then by position
      items.sort((a, b) {
        if (a.isChecked != b.isChecked) return a.isChecked ? 1 : -1;
        return a.position.compareTo(b.position);
      });
      return items;
    });
  }

  Future<NoteItemModel> createItem(
    String uid, String noteId, {
    required String text,
    required double position,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    await _itemsCol(uid, noteId).doc(id).set({
      'text': text,
      'isChecked': false,
      'position': position,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });
    await _notesCol(uid).doc(noteId).update({'updatedAt': Timestamp.fromDate(now)});
    return NoteItemModel(id: id, text: text, position: position, createdAt: now, updatedAt: now);
  }

  Future<void> updateItem(String uid, String noteId, NoteItemModel item) async {
    await _itemsCol(uid, noteId).doc(item.id).update({
      'text': item.text,
      'isChecked': item.isChecked,
      'position': item.position,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> toggleItemChecked(String uid, String noteId, String itemId, bool isChecked) async {
    await _itemsCol(uid, noteId).doc(itemId).update({
      'isChecked': isChecked,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> deleteItem(String uid, String noteId, String itemId) async {
    await _itemsCol(uid, noteId).doc(itemId).delete();
  }
}
