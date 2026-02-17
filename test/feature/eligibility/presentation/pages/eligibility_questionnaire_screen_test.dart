import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelink/feature/eligibility/presentation/pages/eligibility_questionnaire_screen.dart';
import 'package:lifelink/feature/eligibility/presentation/state/eligibility_state.dart';
import 'package:lifelink/feature/eligibility/presentation/view_model/eligibility_view_model.dart';

class FakeEligibilityViewModel extends EligibilityViewModel {
  final EligibilityState _state;
  FakeEligibilityViewModel(this._state);

  @override
  EligibilityState build() => _state;
}

void main() {
  Widget buildTestWidget(EligibilityState state) {
    return ProviderScope(
      overrides: [
        eligibilityViewModelProvider.overrideWith(
          () => FakeEligibilityViewModel(state),
        ),
      ],
      child: const MaterialApp(
        home: EligibilityQuestionnaireScreen(requestType: 'blood'),
      ),
    );
  }

  testWidgets('renders questionnaire title and key fields', (tester) async {
    await tester.pumpWidget(buildTestWidget(const EligibilityState()));
    await tester.pump();

    expect(find.text('Eligibility Questionnaire'), findsOneWidget);
    expect(find.text('Basic Information'), findsOneWidget);
    expect(find.text('Health Conditions'), findsOneWidget);
    expect(find.text('Additional Questions'), findsOneWidget);
  });

  testWidgets('shows submit button on questionnaire screen', (tester) async {
    await tester.pumpWidget(buildTestWidget(const EligibilityState()));
    await tester.pump();

    expect(find.byType(ElevatedButton), findsWidgets);
  });

  testWidgets('renders age and weight input fields', (tester) async {
    await tester.pumpWidget(buildTestWidget(const EligibilityState()));
    await tester.pump();

    expect(find.byType(TextFormField), findsWidgets);
  });

  testWidgets('contains progress-capable scrollable content', (tester) async {
    await tester.pumpWidget(buildTestWidget(const EligibilityState()));
    await tester.pump();

    expect(find.byType(Scrollable), findsWidgets);
  });

  testWidgets('screen remains stable after an extra pump', (tester) async {
    await tester.pumpWidget(buildTestWidget(const EligibilityState()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(Scaffold), findsOneWidget);
  });
}