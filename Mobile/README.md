# Mobile UserFlow

Aplicación Flutter con separación MVVM: View → ViewModel → Repository → Service → API.

## Requisitos y ejecución

```powershell
flutter doctor
flutter create --platforms=android,ios .
flutter pub get
flutter test
flutter run
```

La aplicación usa por defecto la API desplegada en GCP:

```text
https://userflow-gateway-dy9hl9mi.uc.gateway.dev/api
```

Para probar el backend local en Android Emulator ejecute `flutter run --dart-define=API_URL=http://10.0.2.2:8080/api`. En un teléfono físico reemplace `10.0.2.2` por la IP local de la PC.

## Pantallas

- Login y registro, con JWT guardado en `SharedPreferences`.
- Dashboard: cinco servicios independientes cargados con `Future.wait()`.
- Usuarios: listar, detalle, crear, editar y eliminar.
- Concurrencia: seleccionar 2–5 archivos y medir la misma subida secuencial y concurrente.
- Correo: publicar una solicitud que viaja por la API, Pub/Sub y el Cloud Run de notificaciones.

Para una aplicación de producción se recomienda cambiar `SharedPreferences` por almacenamiento seguro del sistema (`flutter_secure_storage`). Se deja sencillo para explicar cada capa en clase.
