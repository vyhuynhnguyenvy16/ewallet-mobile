import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_service.dart';
import 'backend_auth_api.dart';

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(FirebaseAuth.instance),
);

final backendAuthApiProvider = Provider<BackendAuthApi>((ref) {
  final api = BackendAuthApi();
  ref.onDispose(api.close);
  return api;
});

/// Token do auth-service cấp sau khi đăng nhập; chỉ giữ trong bộ nhớ.
class AuthTokensNotifier extends Notifier<AuthTokens?> {
  @override
  AuthTokens? build() => null;

  void save(AuthTokens tokens) => state = tokens;

  void clear() => state = null;
}

final authTokensProvider = NotifierProvider<AuthTokensNotifier, AuthTokens?>(
  AuthTokensNotifier.new,
);
