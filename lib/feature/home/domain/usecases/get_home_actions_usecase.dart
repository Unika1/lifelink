import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelink/feature/home/data/repositories/home_repository_impl.dart';
import 'package:lifelink/feature/home/domain/entities/home_action_entity.dart';
import 'package:lifelink/feature/home/domain/repositories/home_repository.dart';

final getHomeActionsUsecaseProvider = Provider<GetHomeActionsUsecase>((ref) {
  return GetHomeActionsUsecase(repository: ref.read(homeRepositoryProvider));
});

class GetHomeActionsUsecase {
  final IHomeRepository _repository;

  GetHomeActionsUsecase({required IHomeRepository repository})
      : _repository = repository;

  Future<List<HomeActionEntity>> call() {
    return _repository.getHomeActions();
  }
}
