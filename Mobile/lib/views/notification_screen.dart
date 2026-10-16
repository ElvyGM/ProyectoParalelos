import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/viewmodels.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final email = TextEditingController();
  final subject = TextEditingController();
  final message = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    subject.dispose();
    message.dispose();
    super.dispose();
  }

  Future<void> send() async {
    if (email.text.isEmpty || subject.text.isEmpty || message.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Completa todos los campos.')));
      return;
    }
    final ok = await context
        .read<NotificationViewModel>()
        .send(email.text, subject.text, message.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok
            ? 'Mensaje enviado correctamente.'
            : 'Error al enviar mensaje.')));
  }

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(children: [
        const Text('Enviar correo',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Correo destino')),
        TextField(
            controller: subject,
            decoration: const InputDecoration(labelText: 'Asunto')),
        TextField(
            controller: message,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Mensaje')),
        const SizedBox(height: 20),
        Consumer<NotificationViewModel>(builder: (_, vm, __) => FilledButton(
            onPressed: vm.loading ? null : send,
            child: Text(vm.loading ? 'Enviando...' : 'Enviar')))
      ]));
}
