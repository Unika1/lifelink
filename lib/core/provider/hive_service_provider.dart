
import 'package:lifelink/core/services/hive/hive_service.dart';
import 'package:riverpod/riverpod.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});
