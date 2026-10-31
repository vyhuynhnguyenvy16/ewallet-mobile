import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';
import 'backend_auth_api.dart';
import '../dashboard/dashboard_screen.dart';
import '../nfc/nfc_cccd_screen.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  String? _verificationId;
  String? _message;
  bool _isLoading = false;

  /// Số điện thoại cần đăng nhập lại vào backend khi Firebase đã xác thực OTP
  /// nhưng auth-service chưa gọi được (mã OTP chỉ dùng được một lần).
  String? _backendRetryPhone;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    final localNumber = digits.startsWith('0') ? digits.substring(1) : digits;
    if (localNumber.length != 9) {
      setState(() => _message = 'Nhập số điện thoại Việt Nam gồm 10 chữ số.');
      return;
    }
    final phone = '+84$localNumber';

    setState(() {
      _isLoading = true;
      _message = null;
    });

    await ref
        .read(authServiceProvider)
        .sendCode(
          phoneNumber: phone,
          onCodeSent: (verificationId) {
            if (!mounted) return;
            setState(() {
              _verificationId = verificationId;
              _isLoading = false;
              _message = 'Mã OTP đã được gửi. Kiểm tra tin nhắn của bạn.';
            });
          },
          onVerificationCompleted: (credential) async {
            final userCredential = await FirebaseAuth.instance
                .signInWithCredential(credential);
            await _finishLogin(userCredential);
          },
          onVerificationFailed: (error) {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
              _message = _friendlyError(error);
            });
          },
        );
  }

  Future<void> _verifyCode() async {
    final verificationId = _verificationId;
    final code = _codeController.text.trim();
    if (verificationId == null || code.length != 6) {
      setState(() => _message = 'Nhập đủ 6 chữ số của mã OTP.');
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });
    try {
      final userCredential = await ref
          .read(authServiceProvider)
          .verifyCode(verificationId: verificationId, smsCode: code);
      await _finishLogin(userCredential);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _message = _friendlyError(error);
      });
    }
  }

  Future<void> _finishLogin(UserCredential userCredential) async {
    await _logAuthTokens(userCredential);
    await _signInToBackend(userCredential.user?.phoneNumber);
  }

  /// Sau khi Firebase xác thực OTP, đăng nhập vào auth-service để lấy
  /// access/refresh token dùng cho các service khác.
  Future<void> _signInToBackend(String? phoneNumber) async {
    if (!mounted) return;
    if (phoneNumber == null || phoneNumber.isEmpty) {
      setState(() {
        _isLoading = false;
        _message = 'Không đọc được số điện thoại từ tài khoản Firebase.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });
    try {
      final tokens = await ref
          .read(backendAuthApiProvider)
          .loginWithPhone(
            phoneNumber: phoneNumber,
            fcmToken: await _readFcmToken(),
          );
      ref.read(authTokensProvider.notifier).save(tokens);
      if (!mounted) return;
      _openDashboard();
    } on BackendAuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _backendRetryPhone = phoneNumber;
        _message = error.message;
      });
    }
  }

  Future<String?> _readFcmToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (error) {
      debugPrint('Unable to read FCM token: $error');
      return null;
    }
  }

  void _openDashboard() {
    Navigator.of(context).pushAndRemoveUntil<void>(
      MaterialPageRoute<void>(builder: (_) => const DashboardScreen()),
      (route) => false,
    );
  }

  Future<void> _logAuthTokens(UserCredential userCredential) async {
    try {
      final idToken = await userCredential.user?.getIdToken();
      final fcmToken = await FirebaseMessaging.instance.getToken();
      final deviceInfo = await DeviceInfoPlugin().deviceInfo;
      final deviceId = switch (deviceInfo) {
        AndroidDeviceInfo info => info.id,
        IosDeviceInfo info => info.identifierForVendor,
        MacOsDeviceInfo info => info.systemGUID,
        WindowsDeviceInfo info => info.deviceId,
        LinuxDeviceInfo info => info.machineId,
        WebBrowserInfo info => info.userAgent,
        _ => null,
      };

      debugPrint('FCM token: $fcmToken');
      debugPrint('Device ID: $deviceId');
      debugPrint('ID token: $idToken');
    } catch (error) {
      debugPrint('Unable to read auth/device tokens: $error');
    }
  }

  String _friendlyError(FirebaseAuthException error) {
    return switch (error.code) {
      'invalid-phone-number' => 'Số điện thoại không hợp lệ.',
      'invalid-verification-code' => 'Mã OTP không đúng.',
      'session-expired' => 'Mã OTP đã hết hạn. Hãy gửi lại mã mới.',
      'too-many-requests' => 'Bạn thử quá nhiều lần. Vui lòng chờ một chút.',
      _ => error.message ?? 'Không thể đăng nhập lúc này.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final hasCode = _verificationId != null;
    final retryPhone = _backendRetryPhone;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _BrandMark(),
                  const SizedBox(height: 48),
                  Text(
                    'Chào mừng trở lại',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Đăng nhập nhanh bằng số điện thoại để tiếp tục với eWallet.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _phoneController,
                    enabled: !hasCode && !_isLoading,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại',
                      hintText: '0912 345 678',
                      prefixIcon: Icon(CupertinoIcons.phone),
                    ),
                  ),
                  if (hasCode) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _codeController,
                      enabled: !_isLoading,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        labelText: 'Mã OTP',
                        hintText: 'Nhập 6 chữ số',
                        prefixIcon: Icon(CupertinoIcons.lock),
                        counterText: '',
                      ),
                    ),
                  ],
                  if (_message != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      _message!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : retryPhone != null
                        ? () => _signInToBackend(retryPhone)
                        : (hasCode ? _verifyCode : _sendCode),
                    child: _isLoading
                        ? const SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            retryPhone != null
                                ? 'Thử kết nối lại'
                                : hasCode
                                ? 'Xác nhận OTP'
                                : 'Gửi mã OTP',
                          ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const NfcCccdScreen(),
                            ),
                          ),
                    icon: const Icon(
                      CupertinoIcons.antenna_radiowaves_left_right,
                    ),
                    label: const Text('Quét CCCD bằng NFC'),
                  ),
                  if (hasCode) ...[
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => setState(() {
                                _verificationId = null;
                                _backendRetryPhone = null;
                                _message = null;
                              }),
                        child: const Text('Đổi số điện thoại'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            CupertinoIcons.creditcard,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Text('eWallet', style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}
