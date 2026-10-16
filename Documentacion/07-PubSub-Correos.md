# Pub/Sub y correos

## Flujo

1. Flutter llama `POST /api/notifications/send` con un JWT.
2. La API valida los tres campos y publica el JSON en `userflow-notifications`.
3. La suscripción push llama de forma autenticada a `notification-cloud-run`.
4. El servicio decodifica Base64, envía el correo por SMTP y registra el resultado.
5. Si falla devuelve HTTP 500 para que Pub/Sub reintente; si funciona devuelve 204.

## Evidencia presencial

1. En Flutter muestre la pantalla **Correo** y envíe un mensaje.
2. En GCP muestre **Pub/Sub → Temas** y la suscripción push.
3. En **Cloud Run** muestre `userflow-api` y `notification-cloud-run`.
4. Abra los logs de `notification-cloud-run` y enseñe el registro de correo enviado.
5. Abra el correo recibido.
6. En GitHub Actions muestre el workflow verde y los pasos Build, Test, Cloud Build, Terraform Plan y Terraform Apply.

## Archivos clave para explicar

- `terraform/notifications.tf`: crea el tema, la suscripción, permisos, secretos y Cloud Run.
- `Backend/UserFlow.Api/Services/NotificationPublisher.cs`: publica el mensaje.
- `Backend/UserFlow.Notifications/Program.cs`: consume y envía el correo.
- `Mobile/lib/views/notification_screen.dart`: formulario móvil.

Las credenciales SMTP viven en GitHub Secrets y Secret Manager; no están guardadas en el repositorio.
