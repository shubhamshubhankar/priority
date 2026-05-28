import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:priority/data/datasources/firestore_goals_datasource.dart';
import 'package:priority/data/repositories/impl/goals_repository_impl.dart';

class MockFirestoreGoalsDatasource extends Mock implements FirestoreGoalsDatasource {}

void main() {
  late MockFirestoreGoalsDatasource datasource;
  late GoalsRepositoryImpl repository;

  setUp(() {
    datasource = MockFirestoreGoalsDatasource();
    repository = GoalsRepositoryImpl(datasource);
  });

  group('GoalsRepository', () {
    test('watchGoals delegates to datasource', () {
      when(() => datasource.watchGoals('uid')).thenAnswer((_) => const Stream.empty());
      repository.watchGoals('uid');
      verify(() => datasource.watchGoals('uid')).called(1);
    });

    test('toggleGoalComplete passes correct value', () async {
      when(() => datasource.toggleGoalComplete('uid', 'goal1', true)).thenAnswer((_) async {});
      await repository.toggleGoalComplete('uid', 'goal1', true);
      verify(() => datasource.toggleGoalComplete('uid', 'goal1', true)).called(1);
    });

    test('updateProgress delegates to datasource', () async {
      when(() => datasource.updateProgress('uid', 'goal1', 75)).thenAnswer((_) async {});
      await repository.updateProgress('uid', 'goal1', 75);
      verify(() => datasource.updateProgress('uid', 'goal1', 75)).called(1);
    });
  });
}
