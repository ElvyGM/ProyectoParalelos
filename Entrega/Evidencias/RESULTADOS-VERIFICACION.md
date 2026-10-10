# Evidencias verificadas

**Estudiante:** ELVY ANTONIO GRULLÓN MOREL  
**Matrícula:** 1222572

## Despliegue automatizado

- Repositorio: `ElvyGM/ProyectoParalelos`
- Rama: `main`
- Commit funcional: `106710f4557889655527f5fba7ef04e8fad070ad`
- GitHub Actions: ejecución `38027081470`, estado `success`
- Enlace: https://github.com/ElvyGM/ProyectoParalelos/actions/runs/38027081470

## Servicios en Google Cloud

- Proyecto: `semana-3-elvy`
- Región: `us-central1`
- Cloud Run: `userflow-api`
- API Gateway: `userflow-gateway`
- Cloud SQL: `userflow-postgres`, PostgreSQL 16
- Artifact Registry: `userflow`
- Secret Manager: secretos para conexión y JWT
- URL pública: https://userflow-gateway-dy9hl9mi.uc.gateway.dev

## Pruebas ejecutadas

- `dotnet test`: restauración correcta; el proyecto no contiene un ensamblado de pruebas separado.
- `flutter analyze`: sin problemas.
- `flutter test`: todas las pruebas pasaron.
- `flutter build apk --release`: APK generado correctamente.
- Instalación en `emulator-5554`: correcta.
- `GET /health`: `200 OK`.
- Registro: `201 Created`.
- Perfil con Authorization Bearer: `200 OK`.
- CRUD de usuario: crear, consultar, actualizar y eliminar verificados.
- Upload y eliminación de PDF: verificados.
- Los usuarios y archivos temporales de la prueba final se eliminaron.

## Qué demuestra cada componente

| Componente | Evidencia |
|---|---|
| JWT | Los endpoints protegidos aceptan el token emitido por login/register. |
| PostgreSQL | Usuarios y archivos se guardan en Cloud SQL. |
| Terraform | La ejecución crea o actualiza la infraestructura declarada. |
| GitHub Actions | Un push a `main` ejecuta el pipeline completo. |
| Cloud Build | Construye y publica la imagen Docker. |
| Artifact Registry | Conserva la imagen `userflow-api:latest`. |
| Cloud Run | Ejecuta el backend serverless. |
| API Gateway | Publica una URL estable para Mobile. |
| Flutter MVVM | Views, ViewModels, repositories y services están separados. |
| Concurrencia | El dashboard usa `Future.wait`; la pantalla de archivos compara ejecución secuencial y concurrente. |
