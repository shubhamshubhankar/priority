import 'package:equatable/equatable.dart';

import '../../../data/models/note_model.dart';

abstract class NotesState extends Equatable {
  const NotesState();
  @override
  List<Object?> get props => [];
}

class NotesInitial extends NotesState {
  const NotesInitial();
}

class NotesLoading extends NotesState {
  const NotesLoading();
}

class NotesLoaded extends NotesState {
  const NotesLoaded({
    required this.allNotes,
    this.searchQuery = '',
  });

  final List<NoteModel> allNotes;
  final String searchQuery;

  List<NoteModel> get filtered {
    if (searchQuery.isEmpty) return allNotes;
    final q = searchQuery.toLowerCase();
    return allNotes.where((n) => n.title.toLowerCase().contains(q)).toList();
  }

  List<NoteModel> get pinned => filtered.where((n) => n.isPinned).toList();
  List<NoteModel> get unpinned => filtered.where((n) => !n.isPinned).toList();

  NotesLoaded copyWith({List<NoteModel>? allNotes, String? searchQuery}) {
    return NotesLoaded(
      allNotes: allNotes ?? this.allNotes,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [allNotes, searchQuery];
}

class NotesError extends NotesState {
  const NotesError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
