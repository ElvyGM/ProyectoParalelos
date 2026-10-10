# UserFlow — Proyecto final

**Estudiante:** ELVY ANTONIO GRULLÓN MOREL  
**Matrícula:** 1222572  
**Mobile:** Flutter/Dart · **Backend:** ASP.NET Core Web API/C# · **BD:** PostgreSQL

UserFlow administra usuarios y documentos. Incluye registro, login JWT, BCrypt, CRUD, archivos, MVVM, dashboard concurrente y comparación medible de subida secuencial/concurrente.

## Despliegue serverless en GCP

La segunda etapa incluye `terraform/` para Cloud Run, API Gateway, Cloud SQL, Artifact Registry, IAM, Secret Manager, Cloud Logging y Storage; `.github/workflows/deploy.yml` para CI/CD; y `cloudbuild.yaml` para construir/publicar la imagen Docker. Las instrucciones y evidencias están en `Documentacion/06-Despliegue-GCP.md`.

No se incluyen credenciales reales. Cloud SQL genera costos, por lo que debe revisarse el plan antes de aplicar o destruir infraestructura.

## Inicio rápido

1. Instale Docker Desktop y Flutter estable.
2. En `Backend`, copie `.env.example` como `.env` y cambie `JWT_KEY`.
3. Ejecute `docker compose up --build -d`.
4. Compruebe `http://localhost:8080/health` y abra `http://localhost:8080/swagger`.
5. En `Mobile`, si las carpetas nativas no existen todavía, ejecute una sola vez `flutter create --platforms=android,ios .`.
6. Ejecute `flutter pub get` y luego `flutter run --dart-define=API_URL=http://10.0.2.2:8080/api`.

Para un teléfono físico, reemplace `10.0.2.2` por la IP local de la PC y permita el puerto 8080 en el firewall.

## Entrega

No incluya `bin/`, `obj/`, `.dart_tool/`, `build/` ni datos de PostgreSQL. Comprima la carpeta `Proyecto-Elvy` como `Proyecto-Elvy-1222572.rar` usando WinRAR. Los archivos dentro de `Documentacion` forman parte de la entrega.
