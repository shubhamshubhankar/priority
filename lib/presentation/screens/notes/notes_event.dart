import 'package:equatable/equatable.dart';

import '../../../data/models/note_model.dart';

abstract class NotesEvent extends Equatable {
  const NotesEvent();
  @override
  List<Object?> get props => [];
}

class NotesSubscribed extends NotesEvent {
  const NotesSubscribed(this.uid);
  final String uid;
  @override
  List<Object?> get props => [uid];
}

class NoteCreated extends NotesEvent {
  const NoteCreated({required this.uid, this.title = '', this.color});
  final String uid;
  final String title;
  final String? color;
  @override
  List<Object?> get props => [uid, title, color];
}

class NoteUpdated extends NotesEvent {
  const NoteUpdated({required this.uid, required this.note});
  final String uid;
  final NoteModel note;
  @override
  List<Object?> get props => [uid, note];
}

class NoteDeleted extends NotesEvent {
  const NoteDeleted({required this.uid, required this.noteId});
  final String uid;
  final String noteId;
  @override
  List<Object?> get props => [uid, noteId];
}

class NotePinToggled extends NotesEvent {
  const NotePinToggled({required this.uid, required this.noteId, required this.isPinned});
  final String uid;
  final String noteId;
  final bool isPinned;
  @override
  List<Object?> get props => [uid, noteId, isPinned];
}

class NoteSearched extends NotesEvent {
  const NoteSearched(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

class NotesUpdated extends NotesEvent {
  const NotesUpdated(this.notes);
  final List<NoteModel> notes;
  @override
  List<Object?> get props => [notes];
}

class NotesStreamErrored extends NotesEvent {
  const NotesStreamErrored(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
