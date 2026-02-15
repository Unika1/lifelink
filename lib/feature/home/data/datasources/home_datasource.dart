import 'package:lifelink/feature/home/data/models/home_action_model.dart';

abstract interface class IHomeLocalDataSource {
  Future<List<HomeActionModel>> getHomeActions();
}
