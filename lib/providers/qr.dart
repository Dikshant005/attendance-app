import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class QRScanState {
  final bool isProcessing;
  final String? errorMessage;
  final Map<String, String>? lastScannedData;

  QRScanState({
    this.isProcessing = false,
    this.errorMessage,
    this.lastScannedData,
  });

  QRScanState copyWith({
    bool? isProcessing,
    String? errorMessage,
    Map<String, String>? lastScannedData,
  }) {
    return QRScanState(
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage ?? this.errorMessage,
      lastScannedData: lastScannedData ?? this.lastScannedData,
    );
  }
}

class QRScanNotifier extends StateNotifier<QRScanState> {
  QRScanNotifier() : super(QRScanState());

  Future<void> scanQRCode(String studentNumber) async {
    state = state.copyWith(isProcessing: true);

    try {
      final response = await http.post(
        Uri.parse(
            'http://brl_registration_12.sugandhi.tech/manual-attendance/'),
        body: {
          'student_no': studentNumber,
        },
      );

      if (response.statusCode == 200) {
        state = state.copyWith(
          isProcessing: false,
        );
      } else {
        state = state.copyWith(
          errorMessage: 'Failed to post student number to the API',
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
