import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/profile/domain/repositories/profile_repository.dart';
import 'package:lifelink/feature/profile/domain/usecases/get_cached_profile_image_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRepository extends Mock implements IProfileRepository {}

void main() {
  late MockProfileRepository mockRepository;
  late GetCachedProfileImageUsecase usecase;

  setUp(() {
    mockRepository = MockProfileRepository();
    usecase = GetCachedProfileImageUsecase(mockRepository);
  });

  test('calls repository.getCachedProfileImage and returns result', () async {
    const imageUrl = '/uploads/profile.png';

    when(() => mockRepository.getCachedProfileImage())
        .thenAnswer((_) async => const Right(imageUrl));

    final result = await usecase();

    expect(result, const Right(imageUrl));
    verify(() => mockRepository.getCachedProfileImage()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('returns Right(null) when no image is cached', () async {
    when(() => mockRepository.getCachedProfileImage())
        .thenAnswer((_) async => const Right(null));

    final result = await usecase();

    expect(result, const Right<Failure, String?>(null));
  });

  test('returns failure when repository fails', () async {
    const failure = ApiFailure(message: 'Cache read failed');
    when(() => mockRepository.getCachedProfileImage())
        .thenAnswer((_) async => const Left(failure));

    final result = await usecase();

    expect(result, const Left(failure));
  });

  test('usecase instance is created', () {
    expect(usecase, isA<GetCachedProfileImageUsecase>());
  });

  test('mock repository instance is created', () {
    expect(mockRepository, isA<MockProfileRepository>());
  });
}