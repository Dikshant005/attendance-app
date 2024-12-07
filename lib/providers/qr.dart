import 'package:attendance_app/model/person.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class QRScanState {
  final bool isProcessing;
  final String? errorMessage;
  final List<Person> persons;

  QRScanState({
    this.isProcessing = false,
    this.errorMessage,
    this.persons = const [],
  });

  QRScanState copyWith({
    bool? isProcessing,
    String? errorMessage,
    List<Person>? persons,
  }) {
    return QRScanState(
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage ?? this.errorMessage,
      persons: persons ?? this.persons,
    );
  }
}

class QRScanNotifier extends StateNotifier<QRScanState> {
  QRScanNotifier() : super(QRScanState());

  Future<void> scanQRCode(String studentNumber) async {
    state = state.copyWith(isProcessing: true);

    try {
      final response = await http.get(
        Uri.parse('https://your-api-endpoint.com/students/$studentNumber'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final person = Person.fromJson(data);

        state = state.copyWith(
          persons: [...state.persons, person],
          isProcessing: false,
        );
      } else {
        state = state.copyWith(
          errorMessage: 'Failed to load student details',
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
