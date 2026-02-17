import 'package:flutter_test/flutter_test.dart';
import 'package:lifelink/feature/home/domain/entities/home_action_entity.dart';
import 'package:lifelink/feature/home/domain/repositories/home_repository.dart';
import 'package:lifelink/feature/home/domain/usecases/get_home_actions_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockHomeRepository extends Mock implements IHomeRepository {}

void main() {
  late MockHomeRepository mockRepo;
  late GetHomeActionsUsecase usecase;

  final tActions = [
    HomeActionEntity(
      title: 'Blood Banks',
      description: 'Find nearby blood banks',
      routeKey: '/blood-banks',
    ),
  ];

  setUp(() {
    mockRepo = MockHomeRepository();
    usecase = GetHomeActionsUsecase(repository: mockRepo);
  });

  test('calls repository.getHomeActions and returns list', () async {
    when(() => mockRepo.getHomeActions()).thenAnswer((_) async => tActions);

    final result = await usecase();

    expect(result, tActions);
    verify(() => mockRepo.getHomeActions()).called(1);
    verifyNoMoreInteractions(mockRepo);
  });

  test('returns empty list when repository returns empty list', () async {
    when(() => mockRepo.getHomeActions()).thenAnswer((_) async => []);

    final result = await usecase();

    expect(result, isEmpty);
  });

  test('fixture action has non-empty route key', () {
    expect(tActions.first.routeKey, isNotEmpty);
  });

  test('fixture action has non-empty title', () {
    expect(tActions.first.title, isNotEmpty);
  });

  test('fixture action has non-empty description', () {
    expect(tActions.first.description, isNotEmpty);
  });
}