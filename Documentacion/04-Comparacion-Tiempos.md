# Comparación de tiempos

La pantalla **Concurrencia** produce los valores reales durante la demostración; no se inventan tiempos. Seleccione los mismos 2–5 archivos una vez: la aplicación usa el mismo lote para ambas versiones y muestra:

```text
Secuencial:   ____ ms
Concurrente: ____ ms
Diferencia:  ____ ms
Mejora:      ____ %
```

Fórmulas: `diferencia = secuencial - concurrente`; `mejora % = diferencia / secuencial × 100`.

La prueba crea dos copias de cada archivo porque debe ejecutar ambos métodos de verdad. La red local y el tamaño de los archivos influyen en el resultado. La versión concurrente normalmente tarda menos en operaciones I/O; no se garantiza que sea más rápida bajo saturación.
