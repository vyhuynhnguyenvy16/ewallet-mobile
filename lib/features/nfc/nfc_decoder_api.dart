import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import 'nfc_decoder_request.dart';

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
      _endpoint = endpoint ?? Uri.parse(ApiConfig.nfcDecoderUrl);

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
