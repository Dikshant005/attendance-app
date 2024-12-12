import 'package:attendance_app/providers/presentfetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PersonListScreen extends ConsumerStatefulWidget {
  @override
  _PersonListScreenState createState() => _PersonListScreenState();
}

class _PersonListScreenState extends ConsumerState<PersonListScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      try {
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
    final presentState = ref.watch(presentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Present Persons'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : presentState.errorMessage != null
              ? Center(child: Text(presentState.errorMessage!))
              : ListView.builder(
                  itemCount: presentState.present?.length ?? 0,
                  itemBuilder: (context, index) {
                    final person = presentState.present![index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
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
                        trailing: Text(
                          person.branch,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                          ),
                        ),
                        onTap: () {},
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          setState(() {
            isLoading = true;
          });
          await ref.read(presentProvider.notifier).fetchpresentpersons();
          setState(() {
            isLoading = false;
          });
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
