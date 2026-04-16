import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'test_fixtures.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void registerFallbacks() {
  registerFallbackValue(FakeUri());
}

class HttpClientFactory {
  static http.Client returning(String body, {int statusCode = 200}) {
    final mock = MockHttpClient();
    when(() => mock.get(any(), headers: any(named: 'headers')))
        .thenAnswer((_) async => http.Response(body, statusCode));
    when(() => mock.get(any()))
        .thenAnswer((_) async => http.Response(body, statusCode));
    when(() => mock.post(any(),
            headers: any(named: 'headers'), body: any(named: 'body')))
        .thenAnswer((_) async => http.Response(body, statusCode));
    when(() => mock.post(any(), headers: any(named: 'headers')))
        .thenAnswer((_) async => http.Response(body, statusCode));
    return mock;
  }

  static http.Client throwingTimeout() {
    final mock = MockHttpClient();
    when(() => mock.get(any(), headers: any(named: 'headers')))
        .thenThrow(TimeoutException('Connection timed out'));
    when(() => mock.get(any()))
        .thenThrow(TimeoutException('Connection timed out'));
    when(() => mock.post(any(),
            headers: any(named: 'headers'), body: any(named: 'body')))
        .thenThrow(TimeoutException('Connection timed out'));
    when(() => mock.post(any(), headers: any(named: 'headers')))
        .thenThrow(TimeoutException('Connection timed out'));
    return mock;
  }

  static http.Client returningBinanceError(int code, String msg) {
    return returning(
      json.encode(TestFixtures.binanceErrorResponse(code, msg)),
      statusCode: 400,
    );
  }

  /// Returns different responses for sequential GET calls
  static http.Client returningSequence(List<http.Response> responses) {
    final mock = MockHttpClient();
    var callIndex = 0;
    when(() => mock.get(any(), headers: any(named: 'headers')))
        .thenAnswer((_) async {
      final response = responses[callIndex % responses.length];
      callIndex++;
      return response;
    });
    when(() => mock.get(any())).thenAnswer((_) async {
      final response = responses[callIndex % responses.length];
      callIndex++;
      return response;
    });
    return mock;
  }
}
