import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelink/feature/home/data/datasources/home_datasource.dart';
import 'package:lifelink/feature/home/data/models/home_action_model.dart';

final homeLocalDataSourceProvider = Provider<IHomeLocalDataSource>((ref) {
  return HomeLocalDataSource();
});

class HomeLocalDataSource implements IHomeLocalDataSource {
  @override
  Future<List<HomeActionModel>> getHomeActions() async {
    return const [
      HomeActionModel(
        title: 'Nearby hospital',
        description: 'Find nearby hospitals and request donation',
        routeKey: 'hospital_map',
      ),
      HomeActionModel(
        title: 'Blood banks',
        description: 'Explore blood banks and available inventory',
        routeKey: 'blood_bank_map',
      ),
      HomeActionModel(
        title: 'Donation request',
        description: 'Create your blood or organ donation request',
        routeKey: 'donation_type',
      ),
    ];
  }
}
