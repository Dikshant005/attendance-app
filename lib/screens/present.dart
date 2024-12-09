import 'package:attendance_app/providers/presentfetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PersonListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presentstate = ref.watch(presentProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Present Persons'),
      ),
      body: presentstate.isLoading
          ? Center(child: CircularProgressIndicator())
          : presentstate.errorMessage != null
              ? Center(child: Text(presentstate.errorMessage!))
              : ListView.builder(
                  itemCount: presentstate.persons?.length ?? 0,
                  itemBuilder: (context, index) {
                    final person = presentstate.persons![index];
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
          ref.read(presentProvider.notifier).fetchpresentPersons();
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}
