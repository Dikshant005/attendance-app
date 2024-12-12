import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:attendance_app/providers/personfetch.dart';
import 'package:attendance_app/providers/presentfetch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final searchControllerProvider =
    Provider.autoDispose<TextEditingController>((ref) {
  return TextEditingController();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

class RegisteredPersonsScreen extends ConsumerStatefulWidget {
  RegisteredPersonsScreen({Key? key}) : super(key: key);

  @override
  _RegisteredPersonsScreenState createState() =>
      _RegisteredPersonsScreenState();
}

class _RegisteredPersonsScreenState
    extends ConsumerState<RegisteredPersonsScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      try {
        await ref.read(personProvider.notifier).fetchPersons();
        await ref.read(presentProvider.notifier).fetchpresentpersons();
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final personState = ref.watch(personProvider);
    final presentState = ref.watch(presentProvider);
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : personState.errorMessage != null ||
                  presentState.errorMessage != null
              ? Center(
                  child: Text(
                      personState.errorMessage ?? presentState.errorMessage!))
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
                            ref.read(searchQueryProvider.notifier).state =
                                value;
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search by Student Number...',
                            hintStyle:
                                TextStyle(color: Colors.white.withOpacity(0.5)),
                            prefixIcon:
                                const Icon(Icons.search, color: Colors.white),
                            suffixIcon: searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear,
                                        color: Colors.black),
                                    onPressed: () {
                                      searchController.clear();
                                      ref
                                          .read(searchQueryProvider.notifier)
                                          .state = '';
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
                        child: filteredPersons?.isEmpty == true &&
                                searchQuery.isNotEmpty
                            ? const Center(
                                child: Text('No persons found',
                                    style: TextStyle(color: Colors.white)))
                            : ListView.builder(
                                itemCount: filteredPersons?.length ?? 0,
                                itemBuilder: (context, index) {
                                  final person = filteredPersons![index];
                                  final isPresent = presentState.present?.any(
                                        (presentPerson) =>
                                            presentPerson.studentNumber ==
                                            person.studentNumber,
                                      ) ??
                                      false;

                                  return Card(
                                    elevation: 3,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    color: isPresent
                                        ? const Color.fromARGB(
                                                255, 108, 242, 112)
                                            .withOpacity(0.3)
                                        : Colors.white,
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 16),
                                      leading: CircleAvatar(
                                        radius: 24,
                                        backgroundColor: Colors.blueAccent,
                                        child: Text(
                                          person.name.isNotEmpty
                                              ? person.name[0].toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      title: Text(
                                        person.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${person.studentNumber} | ${person.email}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      trailing: ElevatedButton(
                                        onPressed: () async {
                                          await markPersonAsPresent(
                                              context, person.studentNumber);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isPresent
                                              ? Colors.green
                                              : Colors.blue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 10),
                                        ),
                                        child: Text(
                                          isPresent
                                              ? 'Present'
                                              : 'Mark Present',
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                      onTap: () {},
                                    ),
                                  );
                                },
                              )),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          setState(() {
            isLoading = true;
          });
          await ref.read(personProvider.notifier).fetchPersons();
          await ref.read(presentProvider.notifier).fetchpresentpersons();
          setState(() {
            isLoading = false;
          });
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Future<void> markPersonAsPresent(
      BuildContext context, String studentNumber) async {
    final url = Uri.parse(
        'http://brl_registration_12.sugandhi.tech/manual-attendance/');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'meradatabase',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'student_no': studentNumber,
        }),
      );

      if (response.statusCode == 200) {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Success'),
            content: Text(
                'Attendance marked successfully for student no: $studentNumber.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );

        ref.read(presentProvider.notifier).fetchpresentpersons();
      } else {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Error'),
            content: Text(
                'Failed to mark attendance for student no: $studentNumber.\nError Code: ${response.statusCode}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text(
              'An error occurred while marking attendance for student no: $studentNumber.\nDetails: ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
