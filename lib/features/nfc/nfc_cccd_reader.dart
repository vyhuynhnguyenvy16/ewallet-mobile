import 'package:flutter_cccd_vn/dmrtd.dart';

import 'nfc_decoder_request.dart';

class NfcUnavailableException implements Exception {
  const NfcUnavailableException();
}

class NfcCccdReader {
  Future<NfcData> read({
    required String identityNumber,
    required DateTime dateOfBirth,
    required DateTime dateOfExpiry,
    required void Function(String stage) onProgress,
  }) async {
    if (!RegExp(r'^\d{12}$').hasMatch(identityNumber)) {
      throw const FormatException('Số định danh phải gồm 12 chữ số.');
    }

    final status = await NfcProvider.nfcStatus;
    if (status != NfcStatus.enabled) {
      throw const NfcUnavailableException();
    }

    final transport = NfcProvider()..timeout = const Duration(seconds: 30);
    try {
      onProgress('Đưa CCCD lại gần mặt lưng điện thoại');
      await transport.connect(timeout: const Duration(seconds: 60));

      onProgress('Đang xác thực chip');
      final passport = Passport(transport);
      await passport.startSession(
        DBAKey(identityNumber.substring(3), dateOfBirth, dateOfExpiry),
      );

      onProgress('Đang đọc DG1');
      final dg1 = await passport.readEfDG1();
      onProgress('Đang đọc DG2');
      final dg2 = await passport.readEfDG2();
      onProgress('Đang đọc SOD');
      final sod = await passport.readEfSOD();

      return NfcData.fromBytes(
        dg1: dg1.toBytes(),
        dg2: dg2.toBytes(),
        sod: sod.toBytes(),
      );
    } finally {
      await transport.disconnect();
    }
  }
}
