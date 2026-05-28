import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:priority/data/datasources/firestore_notes_datasource.dart';
import 'package:priority/data/repositories/impl/notes_repository_impl.dart';

class MockFirestoreNotesDatasource extends Mock implements FirestoreNotesDatasource {}

void main() {
  late MockFirestoreNotesDatasource datasource;
  late NotesRepositoryImpl repository;

  setUp(() {
    datasource = MockFirestoreNotesDatasource();
    repository = NotesRepositoryImpl(datasource);
  });

  group('NotesRepository', () {
    test('watchNotes delegates to datasource', () {
      when(() => datasource.watchNotes('uid123')).thenAnswer((_) => const Stream.empty());
      repository.watchNotes('uid123');
      verify(() => datasource.watchNotes('uid123')).called(1);
    });

    test('togglePin delegates with correct args', () async {
      when(() => datasource.togglePin('uid', 'note1', true)).thenAnswer((_) async {});
      await repository.togglePin('uid', 'note1', true);
      verify(() => datasource.togglePin('uid', 'note1', true)).called(1);
    });

    test('deleteNote delegates to datasource', () async {
      when(() => datasource.deleteNote('uid', 'note1')).thenAnswer((_) async {});
      await repository.deleteNote('uid', 'note1');
      verify(() => datasource.deleteNote('uid', 'note1')).called(1);
    });
  });
}
