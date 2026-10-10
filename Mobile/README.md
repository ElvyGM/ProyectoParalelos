# Mobile UserFlow

Aplicación Flutter con separación MVVM: View → ViewModel → Repository → Service → API.

## Requisitos y ejecución

```powershell
flutter doctor
flutter create --platforms=android,ios .
flutter pub get
flutter test
flutter run --dart-define=API_URL=http://10.0.2.2:8080/api
```

El comando `flutter create` conserva `lib/` y genera las carpetas nativas. En Android Emulator, `10.0.2.2` apunta a la PC. En teléfono físico use, por ejemplo, `http://192.168.1.20:8080/api`.

## Pantallas

- Login y registro, con JWT guardado en `SharedPreferences`.
- Dashboard: cinco servicios independientes cargados con `Future.wait()`.
- Usuarios: listar, detalle, crear, editar y eliminar.
- Concurrencia: seleccionar 2–5 archivos y medir la misma subida secuencial y concurrente.

Para una aplicación de producción se recomienda cambiar `SharedPreferences` por almacenamiento seguro del sistema (`flutter_secure_storage`). Se deja sencillo para explicar cada capa en clase.
