import 'package:attendance_app/screens/registered.dart';
import 'package:attendance_app/screens/scanner.dart';
import 'package:attendance_app/screens/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bottomNavIndexProvider = StateProvider<int>(
  (ref) => 0,
);

class Bottomnavbar extends ConsumerWidget {
  const Bottomnavbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Widget> screens = [
      Search(),
      QRScanner(),
      RegisteredPersonsScreen(),
    ];

    final currentIndex = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(bottomNavIndexProvider.notifier).state = index;
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.co_present,
            ),
            label: 'present',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_2_rounded), label: "Scan"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_sharp), label: 'Registerd')
        ],
      ),
    );
  }
}
