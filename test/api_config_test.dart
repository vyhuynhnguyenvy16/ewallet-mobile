import 'package:ewallet_mobile/core/config/api_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

// Các test này giả định không truyền --dart-define nào cho API_HOST/*_BASE_URL.
void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  group('ApiConfig', () {
    test('Android Emulator dùng 10.0.2.2, mỗi service một port riêng', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      expect(ApiConfig.host, 'http://10.0.2.2');
      expect(ApiConfig.gateway, 'http://10.0.2.2:8000');
      expect(ApiConfig.auth, 'http://10.0.2.2:8001');
      expect(ApiConfig.user, 'http://10.0.2.2:8002');
      expect(ApiConfig.payment, 'http://10.0.2.2:8004');
      expect(ApiConfig.ocr, 'http://10.0.2.2:8006');
      expect(ApiConfig.notification, 'http://10.0.2.2:8007');
      expect(ApiConfig.chatbot, 'http://10.0.2.2:8008');
      expect(ApiConfig.file, 'http://10.0.2.2:8009');
      expect(ApiConfig.nfcDecoderUrl, 'http://10.0.2.2:8012/api/v1/ekyc/nfc');
    });

    test('iOS Simulator dùng localhost', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      expect(ApiConfig.host, 'http://localhost');
      expect(ApiConfig.auth, 'http://localhost:8001');
    });
  });
}
