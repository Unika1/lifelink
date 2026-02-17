import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelink/core/services/connectivity/network_info.dart';
import 'package:mocktail/mocktail.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late NetworkInfo networkInfo;
  late MockConnectivity mockConnectivity;

  setUp(() {
    mockConnectivity = MockConnectivity();
    networkInfo = NetworkInfo(mockConnectivity);
  });

  group('NetworkInfo', () {
    test('returns false when connectivity result is none', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);

      final result = await networkInfo.isConnected;

      expect(result, false);
      verify(() => mockConnectivity.checkConnectivity()).called(1);
    });

    test('returns bool for non-none connectivity results', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);

      final result = await networkInfo.isConnected;

      expect(result, isA<bool>());
      verify(() => mockConnectivity.checkConnectivity()).called(1);
    });

    test('implements INetworkInfo', () {
      expect(networkInfo, isA<INetworkInfo>());
    });
  });
}