import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QRScanState {
  final bool isProcessing;
  final String? errorMessage;
  final Map<String, dynamic>? personDetails;

  QRScanState({
    required this.isProcessing,
    this.errorMessage,
    this.personDetails,
  });

  QRScanState.initial()
      : isProcessing = false,
        errorMessage = null,
        personDetails = null;

  QRScanState copyWith({
    bool? isProcessing,
    String? errorMessage,
    Map<String, dynamic>? personDetails,
  }) {
    return QRScanState(
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage ?? this.errorMessage,
      personDetails: personDetails ?? this.personDetails,
    );
  }
}

class QRScanNotifier extends StateNotifier<QRScanState> {
  QRScanNotifier() : super(QRScanState.initial());

  Future<void> scanQRCode(String qrData) async {
    if (state.isProcessing) return;
    state = state.copyWith(isProcessing: true);

    try {
      final response = await http.post(
        Uri.parse('https://your-api-endpoint.com/verify'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'qrCode': qrData}),
      );

      if (response.statusCode == 200) {
        final personData = json.decode(response.body);
        state = state.copyWith(personDetails: personData, isProcessing: false);
      } else {
        state = state.copyWith(
          errorMessage: 'Failed to fetch person details',
          isProcessing: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error: $e',
        isProcessing: false,
      );
    }
  }
}

final qrScanProvider =
    StateNotifierProvider<QRScanNotifier, QRScanState>((ref) {
  return QRScanNotifier();
});
