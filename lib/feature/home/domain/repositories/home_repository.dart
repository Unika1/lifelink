import 'package:lifelink/feature/home/domain/entities/home_action_entity.dart';

abstract interface class IHomeRepository {
  Future<List<HomeActionEntity>> getHomeActions();
}
