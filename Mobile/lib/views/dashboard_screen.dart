import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/viewmodels.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<DashboardViewModel>().loadConcurrent();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    if (vm.loading) return const Center(child: CircularProgressIndicator());
    return RefreshIndicator(
        onRefresh: vm.loadConcurrent,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Text('Hola, ${vm.profile?.fullName ?? ''}',
              style: Theme.of(context).textTheme.headlineSmall),
          const Text(
              'Estos bloques se cargaron simultáneamente con Future.wait().'),
          if (vm.error != null)
            Text(vm.error!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          Wrap(spacing: 12, runSpacing: 12, children: [
            _card('Usuarios', '${vm.stats?.users ?? 0}', Icons.people),
            _card('Archivos', '${vm.stats?.files ?? 0}', Icons.folder),
            _card('Mis archivos', '${vm.stats?.myFiles ?? 0}', Icons.person)
          ]),
          const SizedBox(height: 20),
          Text('Notificaciones', style: Theme.of(context).textTheme.titleLarge),
          ...vm.notifications.map((x) => ListTile(
              leading: const Icon(Icons.notifications),
              title: Text(x['title'].toString())))
        ]));
  }

  Widget _card(String title, String value, IconData icon) => Card(
      child: SizedBox(
          width: 150,
          height: 110,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon),
            Text(value,
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Text(title)
          ])));
}
