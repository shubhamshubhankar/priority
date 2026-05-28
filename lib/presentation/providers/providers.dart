import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/datasources/firestore_notes_datasource.dart';
import '../../data/datasources/firestore_tasks_datasource.dart';
import '../../data/datasources/firestore_goals_datasource.dart';
import '../../data/repositories/impl/auth_repository_impl.dart';
import '../../data/repositories/impl/notes_repository_impl.dart';
import '../../data/repositories/impl/tasks_repository_impl.dart';
import '../../data/repositories/impl/goals_repository_impl.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/notes_repository.dart';
import '../../data/repositories/tasks_repository.dart';
import '../../data/repositories/goals_repository.dart';

// Auth state stream
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final currentUidProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).value?.uid;
});

// Datasources
final authDatasourceProvider = Provider<FirebaseAuthDatasource>(
  (_) => FirebaseAuthDatasource(),
);

final notesDatasourceProvider = Provider<FirestoreNotesDatasource>(
  (_) => FirestoreNotesDatasource(),
);

final tasksDatasourceProvider = Provider<FirestoreTasksDatasource>(
  (_) => FirestoreTasksDatasource(),
);

final goalsDatasourceProvider = Provider<FirestoreGoalsDatasource>(
  (_) => FirestoreGoalsDatasource(),
);

// Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authDatasourceProvider));
});

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepositoryImpl(ref.watch(notesDatasourceProvider));
});

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return TasksRepositoryImpl(ref.watch(tasksDatasourceProvider));
});

final goalsRepositoryProvider = Provider<GoalsRepository>((ref) {
  return GoalsRepositoryImpl(ref.watch(goalsDatasourceProvider));
});
