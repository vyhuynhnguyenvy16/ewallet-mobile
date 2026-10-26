import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cccd_vn/cccd_vietnam.dart';
import 'package:uuid/uuid.dart';

import 'nfc_cccd_reader.dart';
import 'nfc_decoder_api.dart';
import 'nfc_decoder_request.dart';

class NfcCccdScreen extends StatefulWidget {
  const NfcCccdScreen({super.key});

  @override
  State<NfcCccdScreen> createState() => _NfcCccdScreenState();
}

class _NfcCccdScreenState extends State<NfcCccdScreen> {
  final _identityNumberController = TextEditingController();
  final _reader = NfcCccdReader();
  final _api = NfcDecoderApi();
  DateTime? _dateOfBirth;
  DateTime? _dateOfExpiry;
  String? _message;
  bool _isLoading = false;

  @override
  void dispose() {
    _identityNumberController.dispose();
    _api.close();
    super.dispose();
  }

  Future<void> _selectDate({required bool isBirthDate}) async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: isBirthDate ? DateTime(1990) : DateTime(now.year + 5),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      helpText: isBirthDate ? 'Chọn ngày sinh' : 'Chọn ngày hết hạn',
    );
    if (selected == null || !mounted) return;
    setState(() {
      if (isBirthDate) {
        _dateOfBirth = selected;
      } else {
        _dateOfExpiry = selected;
      }
      _message = null;
    });
  }

  Future<void> _scanAndSend() async {
    final identityNumber = _identityNumberController.text.trim();
    final dateOfBirth = _dateOfBirth;
    final dateOfExpiry = _dateOfExpiry;
    if (!RegExp(r'^\d{12}$').hasMatch(identityNumber) ||
        dateOfBirth == null ||
        dateOfExpiry == null) {
      setState(() {
        _message = 'Nhập đủ số định danh 12 số, ngày sinh và ngày hết hạn.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = 'Đang khởi tạo NFC';
    });

    try {
      final nfcData = await _reader.read(
        identityNumber: identityNumber,
        dateOfBirth: dateOfBirth,
        dateOfExpiry: dateOfExpiry,
        onProgress: (stage) {
          if (mounted) setState(() => _message = stage);
        },
      );
      if (!mounted) return;
      setState(() => _message = 'Đang gửi dữ liệu lên máy chủ');
      await _api.send(
        NfcDecoderRequest(sessionId: const Uuid().v4(), nfcData: nfcData),
      );
      if (!mounted) return;
      setState(() => _message = 'Đọc và gửi dữ liệu NFC thành công.');
    } on NfcUnavailableException {
      if (mounted) {
        setState(
          () => _message = 'Thiết bị không hỗ trợ NFC hoặc NFC đang tắt.',
        );
      }
    } on CccdOperationCancelledException {
      if (mounted) setState(() => _message = 'Đã hủy phiên quét NFC.');
    } on CccdTimeoutException {
      if (mounted) {
        setState(() => _message = 'Quét NFC quá thời gian. Vui lòng thử lại.');
      }
    } on CccdTagLostException {
      if (mounted) {
        setState(
          () => _message = 'Mất kết nối với thẻ. Hãy giữ điện thoại sát thẻ.',
        );
      }
    } on CccdAuthenticationException {
      if (mounted) {
        setState(
          () => _message =
              'Không mở được chip. Kiểm tra số định danh và ngày tháng đã nhập.',
        );
      }
    } on NfcDecoderApiException catch (error) {
      if (mounted) setState(() => _message = error.toString());
    } on TimeoutException {
      if (mounted) {
        setState(() => _message = 'Máy chủ không phản hồi trong 30 giây.');
      }
    } on FormatException catch (error) {
      if (mounted) setState(() => _message = error.message);
    } on Exception {
      if (mounted) {
        setState(
          () => _message =
              'Không thể hoàn tất quét NFC hoặc gửi dữ liệu. Vui lòng thử lại.',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime? value) {
    if (value == null) return '';
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quét NFC CCCD')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                CupertinoIcons.antenna_radiowaves_left_right,
                size: 52,
              ),
              const SizedBox(height: 16),
              Text(
                'Đọc thông tin từ chip CCCD',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Nhập thông tin in trên thẻ để xác thực chip. Dữ liệu DG1, '
                'DG2 và SOD sẽ được gửi lên máy chủ; ảnh và dữ liệu liveness '
                'chưa được thu thập.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _identityNumberController,
                enabled: !_isLoading,
                keyboardType: TextInputType.number,
                maxLength: 12,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Số định danh',
                  hintText: '12 chữ số',
                  prefixIcon: Icon(CupertinoIcons.person_crop_rectangle),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 16),
              _DateField(
                label: 'Ngày sinh',
                value: _formatDate(_dateOfBirth),
                enabled: !_isLoading,
                onTap: () => _selectDate(isBirthDate: true),
              ),
              const SizedBox(height: 16),
              _DateField(
                label: 'Ngày hết hạn',
                value: _formatDate(_dateOfExpiry),
                enabled: !_isLoading,
                onTap: () => _selectDate(isBirthDate: false),
              ),
              if (_message != null) ...[
                const SizedBox(height: 20),
                Text(
                  _message!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _scanAndSend,
                icon: _isLoading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(CupertinoIcons.antenna_radiowaves_left_right),
                label: Text(_isLoading ? 'Đang quét...' : 'Bắt đầu quét NFC'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(CupertinoIcons.calendar_today),
          enabled: enabled,
        ),
        child: Text(value.isEmpty ? 'Chọn ngày' : value),
      ),
    );
  }
}
