import 'package:attendance_app/providers/searchprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Search extends ConsumerWidget {
  const Search({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchAsyncValue = ref.watch(searchProvider);

    return Scaffold(
      body: searchAsyncValue.when(
        data: (searchData) {
          if (searchData.isEmpty) {
            return const Center(
              child: Text('No results found.'),
            );
          }
          return ListView.builder(
            itemCount: searchData.length,
            itemBuilder: (context, index) {
              final item = searchData[index];
              return ListTile(
              
                onTap: () {
                 
                },
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) {
          return Center(
            child: Text('Error: ${error.toString()}'),
          );
        },
      ),
    );
  }
}
