import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../viewmodels/viewmodels.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});
  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<UsersViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UsersViewModel>();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _form(),
        child: const Icon(Icons.add),
      ),
      body: vm.loading && vm.users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: vm.load,
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  if (vm.error != null)
                    Text(vm.error!, style: const TextStyle(color: Colors.red)),
                  ...vm.users.map(
                    (user) => Card(
                      child: ListTile(
                        leading: CircleAvatar(child: Text(user.nombre[0])),
                        title: Text(user.fullName),
                        subtitle: Text(user.email),
                        onTap: () => _showDetails(user),
                        trailing: Wrap(
                          children: [
                            IconButton(
                                onPressed: () => _form(user),
                                icon: const Icon(Icons.edit)),
                            IconButton(
                              onPressed: () => _confirmDelete(user),
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _showDetails(UserModel user) => showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(user.fullName),
          content: Text(
              'ID: ${user.id}\nCorreo: ${user.email}\nCreado: ${user.createdAt.toLocal()}'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cerrar')),
          ],
        ),
      );

  Future<void> _form([UserModel? user]) async {
    final nombre = TextEditingController(text: user?.nombre);
    final apellido = TextEditingController(text: user?.apellido);
    final email = TextEditingController(text: user?.email);
    final password = TextEditingController();
    final save = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(user == null ? 'Crear usuario' : 'Editar usuario'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nombre,
                  decoration: const InputDecoration(labelText: 'Nombre')),
              TextField(
                  controller: apellido,
                  decoration: const InputDecoration(labelText: 'Apellido')),
              TextField(
                  controller: email,
                  decoration: const InputDecoration(labelText: 'Correo')),
              TextField(
                controller: password,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: user == null
                      ? 'Contraseña'
                      : 'Nueva contraseña (opcional)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Guardar')),
        ],
      ),
    );
    if (save == true && mounted) {
      try {
        await context.read<UsersViewModel>().save(
              user: user,
              nombre: nombre.text,
              apellido: apellido.text,
              email: email.text,
              password: password.text,
            );
      } catch (_) {}
    }
    nombre.dispose();
    apellido.dispose();
    email.dispose();
    password.dispose();
  }

  Future<void> _confirmDelete(UserModel user) async {
    final remove = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar'),
        content: Text('¿Eliminar a ${user.fullName}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('No')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Sí, eliminar')),
        ],
      ),
    );
    if (remove == true && mounted) {
      await context.read<UsersViewModel>().remove(user.id);
    }
  }
}
