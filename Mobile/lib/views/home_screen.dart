import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/viewmodels.dart';
import 'dashboard_screen.dart';
import 'users_screen.dart';
import 'uploads_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  final pages = const [DashboardScreen(), UsersScreen(), UploadsScreen()];
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('UserFlow'), actions: [
        IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await context.read<AuthViewModel>().logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false);
              }
            },
            icon: const Icon(Icons.logout))
      ]),
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (x) => setState(() => index = x),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.dashboard), label: 'Dashboard'),
            NavigationDestination(icon: Icon(Icons.people), label: 'Usuarios'),
            NavigationDestination(
                icon: Icon(Icons.speed), label: 'Concurrencia')
          ]));
}
