import 'dart:typed_data';

class NfcDecoderRequest {
  const NfcDecoderRequest({
    required this.sessionId,
    required this.nfcData,
    this.livenessData,
  });

  final String sessionId;
  final NfcData nfcData;
  final LivenessData? livenessData;

  Map<String, Object?> toJson() => {
    'sessionId': sessionId,
    'nfcData': nfcData.toJson(),
    'livenessData': livenessData?.toJson(),
  };
}

class NfcData {
  const NfcData({
    required this.dg1Hex,
    required this.dg2Hex,
    required this.sodHex,
  });

  factory NfcData.fromBytes({
    required Uint8List dg1,
    required Uint8List dg2,
    required Uint8List sod,
  }) {
    String encode(Uint8List bytes) => bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join()
        .toUpperCase();

    return NfcData(
      dg1Hex: encode(dg1),
      dg2Hex: encode(dg2),
      sodHex: encode(sod),
    );
  }

  final String dg1Hex;
  final String dg2Hex;
  final String sodHex;

  Map<String, String> toJson() => {
    'dg1Hex': dg1Hex,
    'dg2Hex': dg2Hex,
    'sodHex': sodHex,
  };
}

class LivenessData {
  const LivenessData({
    required this.capturedImageBase64,
    required this.actionLogs,
  });

  final String capturedImageBase64;
  final List<ActionLog> actionLogs;

  Map<String, Object?> toJson() => {
    'capturedImageBase64': capturedImageBase64,
    'actionLogs': actionLogs.map((log) => log.toJson()).toList(),
  };
}

class ActionLog {
  const ActionLog({
    required this.action,
    required this.timestamp,
    required this.passed,
  });

  final String action;
  final DateTime timestamp;
  final bool passed;

  Map<String, Object?> toJson() => {
    'action': action,
    'timestamp': timestamp.toUtc().toIso8601String(),
    'passed': passed,
  };
}
