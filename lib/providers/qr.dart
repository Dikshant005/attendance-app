import 'dart:convert';

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
        headers: {
          'Authorization': 'meradatabase',
        },
        body: {
          'student_no': studentNumber,
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        final msg = responseBody['msg'] ?? 'Attendance marking failed';
        print('all okay');

        state = state.copyWith(
          isProcessing: false,
          lastScannedData: {'message': msg},
        );
      } else {
        state = state.copyWith(
          errorMessage:
              'Failed to post student number to the API. Status code: ${response.statusCode}',
          isProcessing: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'An error occurred',
        isProcessing: false,
      );
    }
  }
}

final qrScanProvider =
    StateNotifierProvider<QRScanNotifier, QRScanState>((ref) {
  return QRScanNotifier();
});
