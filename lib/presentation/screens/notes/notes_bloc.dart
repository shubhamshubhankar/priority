import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/notes_repository.dart';
import 'notes_event.dart';
import 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  NotesBloc(this._repository) : super(const NotesInitial()) {
    on<NotesSubscribed>(_onSubscribed);
    on<NotesUpdated>(_onUpdated);
    on<NotesStreamErrored>(_onStreamError);
    on<NoteCreated>(_onCreated);
    on<NoteUpdated>(_onNoteUpdated);
    on<NoteDeleted>(_onDeleted);
    on<NotePinToggled>(_onPinToggled);
    on<NoteSearched>(_onSearched);
  }

  final NotesRepository _repository;
  StreamSubscription? _sub;

  void _onSubscribed(NotesSubscribed event, Emitter<NotesState> emit) {
    emit(const NotesLoading());
    _sub?.cancel();
    _sub = _repository.watchNotes(event.uid).listen(
      (notes) => add(NotesUpdated(notes)),
      onError: (e) => add(NotesStreamErrored(e.toString())),
    );
  }

  void _onUpdated(NotesUpdated event, Emitter<NotesState> emit) {
    final current = state;
    final query = current is NotesLoaded ? current.searchQuery : '';
    emit(NotesLoaded(allNotes: event.notes, searchQuery: query));
  }

  void _onStreamError(NotesStreamErrored event, Emitter<NotesState> emit) {
    emit(NotesError(event.message));
  }

  Future<void> _onCreated(NoteCreated event, Emitter<NotesState> emit) async {
    try {
      await _repository.createNote(event.uid, title: event.title, color: event.color);
    } catch (_) {}
  }

  Future<void> _onNoteUpdated(NoteUpdated event, Emitter<NotesState> emit) async {
    try {
      await _repository.updateNote(event.uid, event.note);
    } catch (_) {}
  }

  Future<void> _onDeleted(NoteDeleted event, Emitter<NotesState> emit) async {
    try {
      await _repository.deleteNote(event.uid, event.noteId);
    } catch (_) {}
  }

  Future<void> _onPinToggled(NotePinToggled event, Emitter<NotesState> emit) async {
    try {
      await _repository.togglePin(event.uid, event.noteId, event.isPinned);
    } catch (_) {}
  }

  void _onSearched(NoteSearched event, Emitter<NotesState> emit) {
    if (state is NotesLoaded) {
      emit((state as NotesLoaded).copyWith(searchQuery: event.query));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
