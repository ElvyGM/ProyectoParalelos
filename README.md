# UserFlow — Proyecto final

**Estudiante:** ELVY ANTONIO GRULLÓN MOREL  
**Matrícula:** 1222572  
**Mobile:** Flutter/Dart · **Backend:** ASP.NET Core Web API/C# · **BD:** PostgreSQL

UserFlow administra usuarios y documentos. Incluye registro, login JWT, BCrypt, CRUD, archivos, MVVM, dashboard concurrente, comparación medible de subida secuencial/concurrente y correos desacoplados con Pub/Sub.

## Despliegue serverless en GCP

Terraform crea Cloud Run, API Gateway, Cloud SQL, Artifact Registry, IAM, Secret Manager, Cloud Logging, Storage y Pub/Sub. El pipeline construye dos imágenes: la API principal y `notification-cloud-run`.

Flujo de correo: `Flutter → API → Pub/Sub → notification-cloud-run → SMTP`.

No se incluyen credenciales reales. Cloud SQL genera costos, por lo que debe revisarse el plan antes de aplicar o destruir infraestructura.

## Inicio rápido

1. Instale Docker Desktop y Flutter estable.
2. En `Backend`, copie `.env.example` como `.env` y cambie `JWT_KEY`.
3. Ejecute `docker compose up --build -d`.
4. Compruebe `http://localhost:8080/health` y abra `http://localhost:8080/swagger`.
5. En `Mobile`, si las carpetas nativas no existen todavía, ejecute una sola vez `flutter create --platforms=android,ios .`.
6. Ejecute `flutter pub get` y luego `flutter run`. La aplicación consume por defecto `https://userflow-gateway-dy9hl9mi.uc.gateway.dev/api`.

Para desplegar la etapa de correos agregue en GitHub los secretos `SMTP_USER` y `SMTP_PASSWORD`. Para Gmail, `SMTP_PASSWORD` debe ser una contraseña de aplicación, no la contraseña normal.

Para un teléfono físico, reemplace `10.0.2.2` por la IP local de la PC y permita el puerto 8080 en el firewall.

La comprobación pública de salud está disponible en `https://userflow-gateway-dy9hl9mi.uc.gateway.dev/health`.

## Entrega

No incluya `bin/`, `obj/`, `.dart_tool/`, `build/` ni datos de PostgreSQL. Comprima la carpeta `Proyecto-Elvy` como `Proyecto-Elvy-1222572.rar` usando WinRAR. Los archivos dentro de `Documentacion` forman parte de la entrega.
