import 'package:flutter/foundation.dart';

/// Địa chỉ các backend service.
///
/// API gateway (8000) chưa áp route cho mọi service nên app gọi thẳng từng
/// service theo port riêng của nó.
///
/// Mặc định:
/// - Android Emulator: `http://10.0.2.2` (trỏ về máy host đang chạy Docker).
/// - iOS Simulator, desktop, web: `http://localhost`.
/// - Điện thoại thật: truyền IP LAN của máy chạy Docker, ví dụ
///   `--dart-define=API_HOST=http://192.168.1.10` (không kèm port).
///
/// Đổi riêng một service bằng URL đầy đủ, ví dụ
/// `--dart-define=AUTH_BASE_URL=http://192.168.1.10:8001`.
class ApiConfig {
  const ApiConfig._();

  static const _hostOverride = String.fromEnvironment('API_HOST');
  static const _gatewayOverride = String.fromEnvironment('GATEWAY_BASE_URL');
  static const _authOverride = String.fromEnvironment('AUTH_BASE_URL');
  static const _userOverride = String.fromEnvironment('USER_BASE_URL');
  static const _paymentOverride = String.fromEnvironment('PAYMENT_BASE_URL');
  static const _ocrOverride = String.fromEnvironment('OCR_BASE_URL');
  static const _notificationOverride = String.fromEnvironment(
    'NOTIFICATION_BASE_URL',
  );
  static const _chatbotOverride = String.fromEnvironment('CHATBOT_BASE_URL');
  static const _fileOverride = String.fromEnvironment('FILE_BASE_URL');
  static const _ekycOverride = String.fromEnvironment('EKYC_BASE_URL');
  static const _nfcUrlOverride = String.fromEnvironment('NFC_API_URL');

  /// Host (không kèm port) của máy đang chạy các service.
  static String get host {
    if (_hostOverride.isNotEmpty) return _trimSlash(_hostOverride);
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2';
    }
    return 'http://localhost';
  }

  static String get gateway => _url(_gatewayOverride, 8000);
  static String get auth => _url(_authOverride, 8001);
  static String get user => _url(_userOverride, 8002);
  static String get payment => _url(_paymentOverride, 8004);
  static String get ocr => _url(_ocrOverride, 8006);
  static String get notification => _url(_notificationOverride, 8007);
  static String get chatbot => _url(_chatbotOverride, 8008);
  static String get file => _url(_fileOverride, 8009);
  static String get ekyc => _url(_ekycOverride, 8012);

  /// Endpoint nhận dữ liệu chip CCCD. `NFC_API_URL` (URL đầy đủ) vẫn dùng được.
  static String get nfcDecoderUrl {
    if (_nfcUrlOverride.isNotEmpty) return _nfcUrlOverride;
    return '$ekyc/api/v1/ekyc/nfc';
  }

  static String _url(String override, int port) {
    if (override.isNotEmpty) return _trimSlash(override);
    return '$host:$port';
  }

  static String _trimSlash(String value) {
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }
}
