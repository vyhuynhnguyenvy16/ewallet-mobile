import 'dart:convert';
import 'dart:typed_data';

import 'package:ewallet_mobile/features/nfc/nfc_decoder_api.dart';
import 'package:ewallet_mobile/features/nfc/nfc_decoder_request.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('NfcData', () {
    test('encodes chip data as uppercase hex', () {
      final data = NfcData.fromBytes(
        dg1: Uint8List.fromList([0x00, 0x01, 0xAB, 0xFF]),
        dg2: Uint8List.fromList([0x10]),
        sod: Uint8List.fromList([0x7F, 0x77]),
      );

      expect(data.toJson(), {
        'dg1Hex': '0001ABFF',
        'dg2Hex': '10',
        'sodHex': '7F77',
      });
    });
  });

  group('NfcDecoderApi', () {
    test('posts the request shape with null liveness data', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url, Uri.parse('http://localhost:8012/api/v1/ekyc/nfc'));
        expect(request.headers['content-type'], 'application/json');
        expect(jsonDecode(request.body), {
          'sessionId': 'session-123',
          'nfcData': {'dg1Hex': '01', 'dg2Hex': '02', 'sodHex': '03'},
          'livenessData': null,
        });
        return http.Response('', 200);
      });
      final api = NfcDecoderApi(
        client: client,
        endpoint: Uri.parse('http://localhost:8012/api/v1/ekyc/nfc'),
      );

      await api.send(
        const NfcDecoderRequest(
          sessionId: 'session-123',
          nfcData: NfcData(dg1Hex: '01', dg2Hex: '02', sodHex: '03'),
        ),
      );
    });

    test('reports non-success HTTP responses', () async {
      final api = NfcDecoderApi(
        client: MockClient((_) async => http.Response('', 401)),
        endpoint: Uri.parse('http://localhost/api/v1/ekyc/nfc'),
      );

      await expectLater(
        api.send(
          const NfcDecoderRequest(
            sessionId: 'session-123',
            nfcData: NfcData(dg1Hex: '01', dg2Hex: '02', sodHex: '03'),
          ),
        ),
        throwsA(
          isA<NfcDecoderApiException>().having(
            (error) => error.statusCode,
            'statusCode',
            401,
          ),
        ),
      );
    });
  });
}
