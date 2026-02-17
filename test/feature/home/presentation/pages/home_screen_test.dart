import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelink/feature/home/presentation/pages/home_screen.dart';

void main() {
  testWidgets('renders home screen shell', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: HomeScreen()),
      ),
    );

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.textContaining('Getting location'), findsOneWidget);
  });

  testWidgets('renders in a ProviderScope', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: HomeScreen()),
      ),
    );

    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('contains at least one scrollable', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: HomeScreen()),
      ),
    );

    expect(find.byType(Scrollable), findsWidgets);
  });

  testWidgets('stays stable after additional pump', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(Scaffold), findsOneWidget);
  });

  testWidgets('shows text widgets', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: HomeScreen()),
      ),
    );

    expect(find.byType(Text), findsWidgets);
  });
}