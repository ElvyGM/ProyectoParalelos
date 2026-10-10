# Arquitectura de UserFlow

**Autor:** ELVY ANTONIO GRULLÓN MOREL (1222572)

```text
Flutter View
    ↓ acciones / observa estado
ViewModel (loading, error, resultados)
    ↓
Repository (casos de uso y modelos)
    ↓
ApiService (HTTP, JSON, JWT, multipart)
    ↓ Authorization: Bearer JWT
ASP.NET Core Controllers
    ↓
Entity Framework Core → PostgreSQL
    ↘ almacenamiento local /uploads
```

La View no conoce HTTP. El ViewModel controla el estado visible. El Repository agrupa operaciones del dominio. El Service construye peticiones. En el backend, los controladores validan la autorización y los DTO evitan exponer `PasswordHash`.

## Datos

- `users`: id, nombre, apellido, email único, passwordHash, foto, createdAt.
- `files`: id, filename seguro, originalName, contentType, size, url, userId, createdAt.

Los archivos tienen relación muchos-a-uno con el usuario. Al eliminar un usuario se eliminan sus referencias de base de datos.
