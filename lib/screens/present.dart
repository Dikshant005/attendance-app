import 'package:attendance_app/providers/qr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PersonListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(qrScanProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Student Details')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              ref.read(qrScanProvider.notifier).scanQRCode('12345');
            },
            child: Text('Scan QR Code'),
          ),
          if (state.isProcessing)
            CircularProgressIndicator()
          else if (state.errorMessage != null)
            Text(state.errorMessage!),
          Expanded(
            child: ListView.builder(
              itemCount: state.persons.length,
              itemBuilder: (context, index) {
                final person = state.persons[index];
                return ListTile(
                  title: Text(person.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Student Number: ${person.studentNumber}'),
                      Text('Email: ${person.email}'),
                      Text('Branch: ${person.branch}'),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
