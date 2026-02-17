import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelink/feature/home/presentation/pages/request_screen.dart';

void main() {
  testWidgets('renders request options', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: RequestScreen()),
    );

    expect(find.text('Donation Requests'), findsOneWidget);
    expect(find.text('Blood Donation Request'), findsOneWidget);
    expect(find.text('Organ Donation Request'), findsOneWidget);
  });

  testWidgets('renders scaffold', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: RequestScreen()),
    );

    expect(find.byType(Scaffold), findsOneWidget);
  });

  testWidgets('shows outlined request buttons', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: RequestScreen()),
    );

    expect(find.byType(OutlinedButton), findsNWidgets(2));
  });

  testWidgets('contains icons for request actions', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: RequestScreen()),
    );

    expect(find.byType(Icon), findsWidgets);
  });

  testWidgets('stays stable after pumpAndSettle', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: RequestScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Donation Requests'), findsOneWidget);
  });
}