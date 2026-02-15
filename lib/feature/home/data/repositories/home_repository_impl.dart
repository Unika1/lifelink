import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelink/feature/home/data/datasources/home_datasource.dart';
import 'package:lifelink/feature/home/data/datasources/local/home_local_datasource.dart';
import 'package:lifelink/feature/home/domain/entities/home_action_entity.dart';
import 'package:lifelink/feature/home/domain/repositories/home_repository.dart';

final homeRepositoryProvider = Provider<IHomeRepository>((ref) {
  return HomeRepositoryImpl(localDataSource: ref.read(homeLocalDataSourceProvider));
});

class HomeRepositoryImpl implements IHomeRepository {
  final IHomeLocalDataSource _localDataSource;

  HomeRepositoryImpl({required IHomeLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<List<HomeActionEntity>> getHomeActions() async {
    final models = await _localDataSource.getHomeActions();
    final List<HomeActionEntity> entities = [];
    for (final model in models) {
      entities.add(model.toEntity());
    }
    return entities;
  }
}
