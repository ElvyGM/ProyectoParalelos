# Guion de demostración (8–10 minutos)

1. Mostrar nombre/matrícula y ejecutar `docker compose up --build -d`.
2. Abrir `/health` y Swagger; mostrar API y PostgreSQL en `docker compose ps`.
3. Registrar a Elvy, iniciar sesión y señalar el JWT.
4. Intentar un endpoint sin token (401); autorizar y repetir (200).
5. Abrir Flutter y explicar las cinco capas MVVM.
6. Entrar al dashboard: cinco endpoints corren simultáneamente con `Future.wait()`.
7. Crear, ver, editar y eliminar un usuario.
8. Elegir 3–5 archivos; ejecutar la comparación y leer ambos tiempos.
9. Mostrar los registros en `/api/files` y eliminar uno.
10. Cerrar explicando que concurrencia solapa I/O; no siempre conviene por dependencias o saturación.

Frase de defensa: “JWT responde quién soy y si puedo entrar; CRUD define qué hago con los datos. BCrypt guarda un hash, no la contraseña. Future.wait espera varios futuros independientes como un grupo.”
