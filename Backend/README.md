# Backend UserFlow

Solución ASP.NET Core 10 con dos servicios pequeños:

- `UserFlow.Api`: PostgreSQL, Entity Framework Core, JWT, BCrypt, CRUD, archivos y publicación en Pub/Sub.
- `UserFlow.Notifications`: recibe el push de Pub/Sub, envía por SMTP y escribe el resultado en Cloud Logging.

## Ejecutar con Docker

```powershell
Copy-Item .env.example .env
docker compose up --build -d
docker compose ps
```

Swagger: `http://localhost:8080/swagger` · Salud: `http://localhost:8080/health`.

## Prueba rápida en Swagger

1. `POST /api/auth/register` con `nombre`, `apellido`, `email` y una contraseña de 6+ caracteres.
2. Copie `token` de la respuesta.
3. En Swagger use **Authorize** e introduzca `Bearer TOKEN` (si la interfaz solicita el valor completo).
4. Pruebe `GET /api/users`, CRUD y `POST /api/upload`.
5. En GCP pruebe `POST /api/notifications/send` con `email`, `subject` y `message`.

## Seguridad

- BCrypt con factor 12; la API nunca retorna `PasswordHash`.
- JWT firmado, con emisor, audiencia y expiración de dos horas.
- Archivos limitados a 10 MB y extensiones JPG/JPEG/PNG/WEBP/PDF.
- Login y registro son públicos; los demás endpoints requieren Bearer token.
- `.env.example` contiene ejemplos, no secretos de producción.

`EnsureCreatedAsync` facilita la demostración académica. En producción se sustituye por migraciones EF versionadas.
