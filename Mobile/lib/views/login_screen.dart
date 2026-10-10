import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/viewmodels.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController(text: 'elvy@example.com');
  final pass = TextEditingController(text: '123456');
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    return Scaffold(
        body: Center(
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(children: [
                      const Icon(Icons.hub, size: 72, color: Colors.indigo),
                      const Text('UserFlow',
                          style: TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold)),
                      const Text('ELVY ANTONIO GRULLÓN MOREL • 1222572'),
                      const SizedBox(height: 28),
                      TextField(
                          controller: email,
                          decoration: const InputDecoration(
                              labelText: 'Correo',
                              border: OutlineInputBorder())),
                      const SizedBox(height: 12),
                      TextField(
                          controller: pass,
                          obscureText: true,
                          decoration: const InputDecoration(
                              labelText: 'Contraseña',
                              border: OutlineInputBorder())),
                      if (vm.error != null)
                        Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(vm.error!,
                                style: const TextStyle(color: Colors.red))),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                          onPressed: vm.loading
                              ? null
                              : () async {
                                  if (await vm.login(email.text, pass.text) &&
                                      context.mounted) {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const HomeScreen()));
                                  }
                                },
                          icon: const Icon(Icons.login),
                          label: vm.loading
                              ? const CircularProgressIndicator()
                              : const Text('Iniciar sesión')),
                      TextButton(
                          onPressed:
                              vm.loading ? null : () => _register(context),
                          child: const Text('Crear una cuenta'))
                    ])))));
  }

  Future<void> _register(BuildContext context) async {
    final n = TextEditingController(text: 'Elvy Antonio');
    final a = TextEditingController(text: 'Grullón Morel');
    final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
                title: const Text('Registro'),
                content: SingleChildScrollView(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(
                      controller: n,
                      decoration: const InputDecoration(labelText: 'Nombre')),
                  TextField(
                      controller: a,
                      decoration: const InputDecoration(labelText: 'Apellido')),
                  TextField(
                      controller: email,
                      decoration: const InputDecoration(labelText: 'Correo')),
                  TextField(
                      controller: pass,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Contraseña (mínimo 6)'))
                ])),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('Cancelar')),
                  FilledButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('Registrar'))
                ]));
    if (ok == true && context.mounted) {
      final vm = context.read<AuthViewModel>();
      if (await vm.register(n.text, a.text, email.text, pass.text) &&
          context.mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    }
  }
}
