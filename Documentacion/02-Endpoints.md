# Endpoints

| Método | Ruta | JWT | Uso |
|---|---|---:|---|
| GET | `/health` | No | Salud de la API |
| POST | `/api/auth/register` | No | Registrar y retornar JWT |
| POST | `/api/auth/login` | No | Autenticar y retornar JWT |
| GET | `/api/users` | Sí | Listar usuarios |
| GET | `/api/users/{id}` | Sí | Detalle |
| POST | `/api/users` | Sí | Crear |
| PUT | `/api/users/{id}` | Sí | Actualizar |
| DELETE | `/api/users/{id}` | Sí | Eliminar |
| GET | `/api/profile` | Sí | Usuario autenticado |
| GET | `/api/stats` | Sí | Estadísticas |
| GET | `/api/notifications` | Sí | Funcionalidad adicional |
| GET | `/api/files` | Sí | Listar archivos |
| POST | `/api/upload` | Sí | Subir multipart, campo `file` |
| DELETE | `/api/upload/{id}` | Sí | Eliminar archivo propio |

Respuesta de login: `{ token, expiresAt, user }`. Todas las respuestas de usuario omiten el hash. Errores comunes: 400 validación, 401 token ausente/inválido, 403 sin permiso, 404 no existe, 409 email duplicado.
