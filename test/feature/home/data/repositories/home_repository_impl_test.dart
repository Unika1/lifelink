import 'package:flutter_test/flutter_test.dart';
import 'package:lifelink/feature/home/data/datasources/home_datasource.dart';
import 'package:lifelink/feature/home/data/models/home_action_model.dart';
import 'package:lifelink/feature/home/data/repositories/home_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class MockHomeLocalDataSource extends Mock implements IHomeLocalDataSource {}

void main() {
  late MockHomeLocalDataSource mockLocal;
  late HomeRepositoryImpl repository;

  final tModel = HomeActionModel(
    title: 'Blood Banks',
    description: 'Find nearby blood banks',
    routeKey: '/blood-banks',
  );

  setUp(() {
    mockLocal = MockHomeLocalDataSource();
    repository = HomeRepositoryImpl(localDataSource: mockLocal);
  });

  test('getHomeActions maps models to entities', () async {
    when(() => mockLocal.getHomeActions()).thenAnswer((_) async => [tModel]);

    final result = await repository.getHomeActions();

    expect(result, hasLength(1));
    expect(result.first.title, 'Blood Banks');
    expect(result.first.description, 'Find nearby blood banks');
    verify(() => mockLocal.getHomeActions()).called(1);
  });

  test('mapped entity keeps routeKey', () async {
    when(() => mockLocal.getHomeActions()).thenAnswer((_) async => [tModel]);

    final result = await repository.getHomeActions();

    expect(result.first.routeKey, '/blood-banks');
  });

  test('returns empty list when datasource returns empty list', () async {
    when(() => mockLocal.getHomeActions()).thenAnswer((_) async => []);

    final result = await repository.getHomeActions();

    expect(result, isEmpty);
  });

  test('fixture model title is not empty', () {
    expect(tModel.title, isNotEmpty);
  });

  test('fixture model description is not empty', () {
    expect(tModel.description, isNotEmpty);
  });
}