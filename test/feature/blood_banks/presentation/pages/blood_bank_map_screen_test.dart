import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lifelink/feature/blood_banks/domain/entities/blood_bank_entity.dart';
import 'package:lifelink/feature/blood_banks/presentation/pages/blood_bank_map_screen.dart';
import 'package:lifelink/feature/blood_banks/presentation/state/blood_bank_state.dart';
import 'package:lifelink/feature/blood_banks/presentation/view_model/blood_bank_viewmodel.dart';

class FakeBloodBankViewModel extends BloodBankViewModel {
  FakeBloodBankViewModel(this._initialState);

  final BloodBankState _initialState;

  @override
  BloodBankState build() => _initialState;

  @override
  Future<void> getAllBloodBanks({
    String? city,
    String? filterState,
    String? bloodType,
    bool? isActive,
    double? latitude,
    double? longitude,
    double? radiusKm,
  }) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const geolocatorChannel = MethodChannel('flutter.baseflow.com/geolocator');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(geolocatorChannel, (methodCall) async {
      if (methodCall.method == 'isLocationServiceEnabled') {
        return false;
      }
      if (methodCall.method == 'checkPermission') {
        return 1;
      }
      if (methodCall.method == 'requestPermission') {
        return 1;
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(geolocatorChannel, null);
  });

  Widget buildTestWidget(BloodBankState state) {
    return ProviderScope(
      overrides: [
        bloodBankViewModelProvider.overrideWith(
          () => FakeBloodBankViewModel(state),
        ),
      ],
      child: const MaterialApp(
        home: BloodBankMapScreen(enableTileLayer: false),
      ),
    );
  }

  testWidgets('renders map page shell and filters', (tester) async {
    const state = BloodBankState(status: BloodBankStatus.loaded, bloodBanks: []);

    await tester.pumpWidget(buildTestWidget(state));
    await tester.pump();

    expect(find.text('Nearby Blood Banks'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('A+'), findsOneWidget);
    expect(find.text('O-'), findsOneWidget);
  });

  testWidgets('shows blood bank item when loaded', (tester) async {
    const bloodBank = BloodBankEntity(
      id: 'bb-1',
      name: 'Central Blood Bank',
      email: 'bb@test.com',
      phoneNumber: '9800000000',
      address: BloodBankAddressEntity(
        street: 'Main St',
        city: 'Kathmandu',
        state: 'Bagmati',
        zipCode: '44600',
      ),
    );

    const state = BloodBankState(
      status: BloodBankStatus.loaded,
      bloodBanks: [bloodBank],
    );

    await tester.pumpWidget(buildTestWidget(state));
    await tester.pump();

    expect(find.text('Central Blood Bank'), findsOneWidget);
    expect(find.text('Kathmandu, Bagmati'), findsOneWidget);
  });
}