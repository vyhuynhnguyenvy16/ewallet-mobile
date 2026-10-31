import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';

class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    this.isNewAccount = false,
  });

  final String accessToken;
  final String refreshToken;
  final bool isNewAccount;
}

class BackendAuthException implements Exception {
  const BackendAuthException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Client cho auth-service (`/api/v1/auth/*`).
class BackendAuthApi {
  BackendAuthApi({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _ownsClient = client == null,
      _baseUrl = baseUrl ?? ApiConfig.auth;

  final http.Client _client;
  final bool _ownsClient;
  final String _baseUrl;

  /// `POST /api/v1/auth/phone`.
  Future<AuthTokens> loginWithPhone({
    required String phoneNumber,
    String? fcmToken,
  }) async {
    final body = await _post('/api/v1/auth/phone', {
      'phoneNumber': phoneNumber,
      if (fcmToken != null) 'fcmToken': fcmToken,
    });
    return _readTokens(body);
  }

  /// `POST /api/v1/auth/refresh`.
  Future<AuthTokens> refresh(String refreshToken) async {
    final body = await _post('/api/v1/auth/refresh', {
      'refreshToken': refreshToken,
    });
    return _readTokens(body);
  }

  /// `POST /api/v1/auth/signout`.
  Future<void> signOut({
    required String accessToken,
    required String refreshToken,
    String? fcmToken,
  }) async {
    await _post(
      '/api/v1/auth/signout',
      {'refreshToken': refreshToken, if (fcmToken != null) 'fcmToken': fcmToken},
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }

  void close() {
    if (_ownsClient) {
      _client.close();
    }
  }

  Future<Object?> _post(
    String path,
    Map<String, Object?> body, {
    Map<String, String> headers = const {},
  }) async {
    final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse('$_baseUrl$path'),
            headers: {'Content-Type': 'application/json', ...headers},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw BackendAuthException(
        'auth-service ($_baseUrl) phản hồi quá lâu. Hãy thử lại.',
      );
    } catch (_) {
      throw BackendAuthException(
        'Không kết nối được auth-service ($_baseUrl). '
        'Kiểm tra service đã chạy và địa chỉ API_HOST.',
      );
    }

    final decoded = _tryDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic> ? decoded['message'] : null;
      throw BackendAuthException(
        message is String && message.isNotEmpty
            ? message
            : 'auth-service trả về HTTP ${response.statusCode}.',
        statusCode: response.statusCode,
      );
    }
    return decoded;
  }

  Object? _tryDecode(String body) {
    if (body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } on FormatException {
      return null;
    }
  }

  AuthTokens _readTokens(Object? body) {
    final data = body is Map<String, dynamic> ? body['data'] : null;
    if (data is Map<String, dynamic>) {
      final accessToken = data['accessToken'];
      final refreshToken = data['refreshToken'];
      if (accessToken is String && refreshToken is String) {
        return AuthTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
          isNewAccount: data['isNewAcc'] == true,
        );
      }
    }
    throw const BackendAuthException('Phản hồi đăng nhập không hợp lệ.');
  }
}
