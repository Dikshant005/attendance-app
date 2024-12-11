import 'package:attendance_app/model/person.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class presentstate {
  final bool isLoading;
  final List<Person>? present;
  final String? errorMessage;

  presentstate({
    required this.isLoading,
    this.present,
    this.errorMessage,
  });

  presentstate.initial()
      : isLoading = true,
        present = [],
        errorMessage = null;

  presentstate copyWith({
    bool? isLoading,
    List<Person>? present,
    String? errorMessage,
  }) {
    return presentstate(
      isLoading: isLoading ?? this.isLoading,
      present: present ?? this.present,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class presentnotifier extends StateNotifier<presentstate> {
  presentnotifier() : super(presentstate.initial());

  Future<void> fetchpresentpersons() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await http
          .get(Uri.parse('http://brl_registration_12.sugandhi.tech/students/'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<Person> present = (jsonData['members'] as List)
            .map((data) => Person.fromJson(data))
            .toList();

        state = state.copyWith(present: present, isLoading: false);
      } else {
        state = state.copyWith(
            errorMessage: 'Failed to load data', isLoading: false);
      }
    } catch (e) {
      state =
          state.copyWith(errorMessage: 'Error Showing data', isLoading: false);
    }
  }
}

final presentProvider =
    StateNotifierProvider<presentnotifier, presentstate>((ref) {
  return presentnotifier();
});
