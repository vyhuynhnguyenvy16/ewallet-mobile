import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'nfc_decoder_request.dart';

const _defaultNfcApiUrl = 'http://10.0.2.2:8012/api/v1/ekyc/nfc';

class NfcDecoderApiException implements Exception {
  const NfcDecoderApiException(this.statusCode);

  final int statusCode;

  @override
  String toString() => 'NFC API trả về HTTP $statusCode.';
}

class NfcDecoderApi {
  NfcDecoderApi({http.Client? client, Uri? endpoint})
    : _client = client ?? http.Client(),
      _ownsClient = client == null,
      _endpoint =
          endpoint ??
          Uri.parse(
            const String.fromEnvironment(
              'NFC_API_URL',
              defaultValue: _defaultNfcApiUrl,
            ),
          );

  final http.Client _client;
  final bool _ownsClient;
  final Uri _endpoint;

  Future<void> send(NfcDecoderRequest request) async {
    final response = await _client
        .post(
          _endpoint,
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode(request.toJson()),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw NfcDecoderApiException(response.statusCode);
    }
  }

  void close() {
    if (_ownsClient) {
      _client.close();
    }
  }
}
