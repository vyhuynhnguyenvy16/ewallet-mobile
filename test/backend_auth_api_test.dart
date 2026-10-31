import 'dart:convert';

import 'package:ewallet_mobile/features/auth/backend_auth_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response _json(Object body, int status) => http.Response(
  jsonEncode(body),
  status,
  headers: const {'content-type': 'application/json'},
);

void main() {
  group('BackendAuthApi', () {
    test('đăng nhập bằng số điện thoại và đọc token', () async {
      final api = BackendAuthApi(
        baseUrl: 'http://auth.test',
        client: MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url, Uri.parse('http://auth.test/api/v1/auth/phone'));
          expect(request.headers['content-type'], contains('application/json'));
          expect(jsonDecode(request.body), {
            'phoneNumber': '+84912345678',
            'fcmToken': 'fcm-1',
          });
          return _json({
            'success': true,
            'data': {
              'accessToken': 'access-1',
              'refreshToken': 'refresh-1',
              'isNewAcc': true,
            },
          }, 200);
        }),
      );

      final tokens = await api.loginWithPhone(
        phoneNumber: '+84912345678',
        fcmToken: 'fcm-1',
      );

      expect(tokens.accessToken, 'access-1');
      expect(tokens.refreshToken, 'refresh-1');
      expect(tokens.isNewAccount, isTrue);
    });

    test('bỏ fcmToken khỏi request khi không có', () async {
      final api = BackendAuthApi(
        baseUrl: 'http://auth.test',
        client: MockClient((request) async {
          expect(jsonDecode(request.body), {'phoneNumber': '+84912345678'});
          return _json({
            'data': {'accessToken': 'a', 'refreshToken': 'r'},
          }, 200);
        }),
      );

      final tokens = await api.loginWithPhone(phoneNumber: '+84912345678');

      expect(tokens.isNewAccount, isFalse);
    });

    test('lấy message lỗi từ phản hồi của service', () async {
      final api = BackendAuthApi(
        baseUrl: 'http://auth.test',
        client: MockClient(
          (_) async => _json({'status': 401, 'message': 'Invalid account'}, 401),
        ),
      );

      await expectLater(
        api.loginWithPhone(phoneNumber: '+84912345678'),
        throwsA(
          isA<BackendAuthException>()
              .having((e) => e.statusCode, 'statusCode', 401)
              .having((e) => e.message, 'message', 'Invalid account'),
        ),
      );
    });

    test('báo lỗi dễ hiểu khi không kết nối được service', () async {
      final api = BackendAuthApi(
        baseUrl: 'http://auth.test',
        client: MockClient((_) async => throw http.ClientException('refused')),
      );

      await expectLater(
        api.loginWithPhone(phoneNumber: '+84912345678'),
        throwsA(
          isA<BackendAuthException>().having(
            (e) => e.message,
            'message',
            contains('http://auth.test'),
          ),
        ),
      );
    });

    test('signOut gửi Bearer token', () async {
      final api = BackendAuthApi(
        baseUrl: 'http://auth.test',
        client: MockClient((request) async {
          expect(request.url, Uri.parse('http://auth.test/api/v1/auth/signout'));
          expect(request.headers['authorization'], 'Bearer access-1');
          expect(jsonDecode(request.body), {'refreshToken': 'refresh-1'});
          return _json({'success': true}, 200);
        }),
      );

      await api.signOut(accessToken: 'access-1', refreshToken: 'refresh-1');
    });
  });
}
