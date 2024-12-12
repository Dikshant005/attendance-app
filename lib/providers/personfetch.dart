import 'package:attendance_app/model/person.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PersonState {
  final bool isLoading;
  final List<Person>? persons;
  final String? errorMessage;

  PersonState({
    required this.isLoading,
    this.persons,
    this.errorMessage,
  });

  PersonState.initial()
      : isLoading = true,
        persons = [],
        errorMessage = null;

  PersonState copyWith({
    bool? isLoading,
    List<Person>? persons,
    String? errorMessage,
  }) {
    return PersonState(
      isLoading: isLoading ?? this.isLoading,
      persons: persons ?? this.persons,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class PersonNotifier extends StateNotifier<PersonState> {
  PersonNotifier() : super(PersonState.initial());

  Future<void> fetchPersons() async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await http.get(
        Uri.parse('http://brl_registration_12.sugandhi.tech/member'),
        headers: {
          'Authorization': 'meradatabase',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<Person> persons = (jsonData['members'] as List)
            .map((data) => Person.fromJson(data))
            .toList();

        state = state.copyWith(persons: persons, isLoading: false);
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

final personProvider =
    StateNotifierProvider<PersonNotifier, PersonState>((ref) {
  return PersonNotifier();
});
