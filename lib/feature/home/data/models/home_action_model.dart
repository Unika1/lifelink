import 'package:lifelink/feature/home/domain/entities/home_action_entity.dart';

class HomeActionModel {
  final String title;
  final String description;
  final String routeKey;

  const HomeActionModel({
    required this.title,
    required this.description,
    required this.routeKey,
  });

  HomeActionEntity toEntity() {
    return HomeActionEntity(
      title: title,
      description: description,
      routeKey: routeKey,
    );
  }
}
