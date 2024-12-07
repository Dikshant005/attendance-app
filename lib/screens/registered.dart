import 'package:attendance_app/providers/personfetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisteredPersonsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personState = ref.watch(personProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Registered Persons'),
      ),
      body: personState.isLoading
          ? Center(child: CircularProgressIndicator())
          : personState.errorMessage != null
              ? Center(child: Text(personState.errorMessage!))
              : ListView.builder(
                  itemCount: personState.persons?.length ?? 0,
                  itemBuilder: (context, index) {
                    final person = personState.persons![index];
                    return ListTile(
                      title: Text(person.name),
                      subtitle:
                          Text('${person.studentNumber} | ${person.email}'),
                      trailing: Text(person.branch),
                      onTap: () {},
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(personProvider.notifier).fetchPersons();
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}
