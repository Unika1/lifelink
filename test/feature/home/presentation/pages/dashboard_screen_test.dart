import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelink/feature/home/presentation/pages/dashboard_screen.dart';

void main() {
  testWidgets('renders dashboard with bottom navigation', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: DashboardScreen()),
    );

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Request'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('renders scaffold', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));

    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('has three navigation labels', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Request'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('dashboard remains stable after pumpAndSettle', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });

  testWidgets('contains bottom navigation items', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Request'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}