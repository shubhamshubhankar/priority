import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:priority/data/datasources/firestore_tasks_datasource.dart';
import 'package:priority/data/models/task_model.dart';
import 'package:priority/data/repositories/impl/tasks_repository_impl.dart';

class MockFirestoreTasksDatasource extends Mock implements FirestoreTasksDatasource {}

void main() {
  late MockFirestoreTasksDatasource datasource;
  late TasksRepositoryImpl repository;

  setUp(() {
    datasource = MockFirestoreTasksDatasource();
    repository = TasksRepositoryImpl(datasource);
  });

  group('TasksRepository', () {
    test('watchTasks delegates to datasource', () {
      when(() => datasource.watchTasks('uid')).thenAnswer((_) => const Stream.empty());
      repository.watchTasks('uid');
      verify(() => datasource.watchTasks('uid')).called(1);
    });

    test('toggleTaskComplete passes correct isCompleted=true', () async {
      when(() => datasource.toggleTaskComplete('uid', 'task1', true)).thenAnswer((_) async {});
      await repository.toggleTaskComplete('uid', 'task1', true);
      verify(() => datasource.toggleTaskComplete('uid', 'task1', true)).called(1);
    });

    test('toggleTaskComplete passes correct isCompleted=false', () async {
      when(() => datasource.toggleTaskComplete('uid', 'task1', false)).thenAnswer((_) async {});
      await repository.toggleTaskComplete('uid', 'task1', false);
      verify(() => datasource.toggleTaskComplete('uid', 'task1', false)).called(1);
    });
  });

  group('Quadrant enum', () {
    test('all quadrants have names', () {
      expect(Quadrant.doNow.name, 'doNow');
      expect(Quadrant.schedule.name, 'schedule');
      expect(Quadrant.delegate.name, 'delegate');
      expect(Quadrant.eliminate.name, 'eliminate');
    });
  });
}
