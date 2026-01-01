import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelink/app.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lifelink/core/services/hive/hive_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Ensure Hive adapters are registered and boxes are open before app start
  final hiveService = HiveService();
  await hiveService.openBoxes();

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
