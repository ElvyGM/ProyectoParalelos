import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/viewmodels.dart';

class UploadsScreen extends StatelessWidget {
  const UploadsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UploadViewModel>();
    final r = vm.result;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text('Prueba secuencial vs concurrente',
          style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 8),
      const Text(
          'Selecciona 2–5 imágenes o PDF. La app sube el mismo lote primero uno por uno y luego en paralelo con Future.wait().'),
      const SizedBox(height: 16),
      FilledButton.icon(
          onPressed: vm.loading
              ? null
              : () async {
                  final picked = await FilePicker.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'pdf']);
                  final paths = picked
                      .map((file) => file.path)
                      .whereType<String>()
                      .take(5)
                      .toList();
                  if (paths.isNotEmpty && context.mounted) {
                    await context.read<UploadViewModel>().compare(paths);
                  }
                },
          icon: const Icon(Icons.upload_file),
          label: Text(vm.loading ? 'Procesando...' : 'Seleccionar y comparar')),
      if (vm.loading) const LinearProgressIndicator(),
      if (vm.error != null)
        Text(vm.error!, style: const TextStyle(color: Colors.red)),
      if (r != null)
        Card(
            margin: const EdgeInsets.only(top: 20),
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Resultado (${r.files} archivos por prueba)',
                          style: Theme.of(context).textTheme.titleLarge),
                      Text('Secuencial: ${r.sequentialMs} ms'),
                      Text('Concurrente: ${r.concurrentMs} ms'),
                      Text('Diferencia: ${r.savedMs} ms'),
                      Text('Mejora: ${r.improvement.toStringAsFixed(1)} %',
                          style: const TextStyle(fontWeight: FontWeight.bold))
                    ]))),
      const SizedBox(height: 16),
      const Text(
          'Nota: se crean dos copias por archivo para medir ambos métodos con el mismo lote. Puedes eliminarlas desde Swagger o extender esta vista.')
    ]);
  }
}
