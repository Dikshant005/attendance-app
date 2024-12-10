import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:attendance_app/providers/personfetch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final searchControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
  return TextEditingController();
});

final searchQueryProvider = StateProvider<String>((ref) => ''); 

final selectedIndexProvider = StateProvider<int?>((ref) => null); 

class RegisteredPersonsScreen extends ConsumerWidget {
  RegisteredPersonsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personState = ref.watch(personProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final searchController = ref.watch(searchControllerProvider);
    final filteredPersons = personState.persons?.where((person) {
      final query = searchQuery.trim().toLowerCase();
      if (query.isEmpty) return true;
      return person.studentNumber.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registered Persons'),
      ),
      body: personState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : personState.errorMessage != null
              ? Center(child: Text(personState.errorMessage!))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          controller: searchController,
                          onChanged: (value) {
                            ref.read(searchQueryProvider.notifier).state = value;
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search by Student Number...',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                            prefixIcon: const Icon(Icons.search, color: Colors.white),
                            suffixIcon: searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: Colors.black),
                                    onPressed: () {
                                      searchController.clear();
                                      ref.read(searchQueryProvider.notifier).state = '';
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(10),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: filteredPersons?.isEmpty == true && searchQuery.isNotEmpty
                          ? const Center(child: Text('No persons found', style: TextStyle(color: Colors.white)))
                          : ListView.builder(
                              itemCount: filteredPersons?.length ?? 0,
                              itemBuilder: (context, index) {
                                final person = filteredPersons![index];
                                final isSelected = ref.watch(selectedIndexProvider) == index;

                                return GestureDetector(
                                  onTap: () async {
                                    if (!isSelected) {
                                      ref.read(selectedIndexProvider.notifier).state = index;
                                    }
                                    await postStudentNumber(person.studentNumber);
                                  },
                                  child: Container(
                                    color: isSelected
                                        ? Colors.lightGreen.withOpacity(0.3) 
                                        : Colors.transparent,
                                    child: ListTile(
                                      leading: GestureDetector(
                                        onTap: () {
                                          if (!isSelected) {
                                            ref.read(selectedIndexProvider.notifier).state = index;
                                          }
                                        },
                                        child: Icon(
                                          Icons.check_circle,
                                          color: isSelected ? Colors.green : Colors.grey,
                                        ),
                                      ),
                                      title: Text(person.name),
                                      subtitle: Text('${person.studentNumber} | ${person.email}'),
                                      trailing: Text(person.branch),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(personProvider.notifier).fetchPersons();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Future<void> postStudentNumber(String studentNumber) async {
    final url = Uri.parse('http://brl_registration_12.sugandhi.tech/manual-attendance/');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'student_no': studentNumber,
        }),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('Attendance posted successfully');
      } else {
        print('Failed to post attendance: ${response.statusCode}');
        print('Error details: ${response.body}');
      }
    } catch (e) {
      print('Error posting attendance: $e');
    }
  }
}
