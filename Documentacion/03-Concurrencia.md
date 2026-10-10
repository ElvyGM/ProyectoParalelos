# Concurrencia

## Dashboard

`DashboardViewModel.loadConcurrent()` usa un solo `Future.wait()` para iniciar al mismo tiempo usuarios, perfil, estadísticas, archivos y notificaciones. Son operaciones de entrada/salida independientes; ninguna necesita el resultado de otra.

## Proceso práctico

`UploadViewModel` implementa las dos versiones exigidas:

```dart
for (final path in paths) {
  await repository.upload(path); // secuencial
}

await Future.wait(paths.map(repository.upload)); // concurrente
```

Un `Stopwatch` mide milisegundos antes y después de cada prueba. Con cinco archivos, `Future.wait` crea cinco futuros; no crea necesariamente cinco hilos. La mejora proviene de solapar esperas de red y servidor.

## Cuándo no conviene

No debe usarse si una tarea depende de la anterior, si importa un orden estricto, si demasiadas solicitudes saturan red/API/BD, o si el servidor limita conexiones. En producción conviene limitar el tamaño del lote y manejar reintentos individualmente.
