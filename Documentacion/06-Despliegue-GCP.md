# Despliegue Serverless en Google Cloud

## Arquitectura

`Flutter -> API Gateway -> Cloud Run -> Cloud SQL PostgreSQL`

GitHub Actions valida y compila .NET, autentica con GCP, ejecuta Terraform y usa Cloud Build para publicar la imagen en Artifact Registry. Cloud Run obtiene `DATABASE_URL` y `JWT_SECRET` desde Secret Manager. Cloud Logging recibe automáticamente los logs del contenedor y Terraform crea la métrica `userflow-api-errors`.

## Secrets de GitHub

En `Settings > Secrets and variables > Actions`, crear:

- `GCP_PROJECT_ID`: ID real del proyecto.
- `GCP_REGION`: por ejemplo `us-central1`.
- `GCP_SA_KEY`: JSON completo de la cuenta CI/CD.
- `JWT_SECRET`: texto aleatorio de 32 caracteres o más.
- `DATABASE_URL`: conexión PostgreSQL externa; si se deja vacía, Terraform usa la instancia Cloud SQL creada.
- `ARTIFACT_REGISTRY` (opcional): `userflow`.
- `CLOUD_RUN_SERVICE` (opcional): `userflow-api`.

No subir claves JSON, contraseñas ni archivos `.auto.tfvars.json` al repositorio.

## Preparación inicial

1. Crear un proyecto GCP con facturación habilitada.
2. Crear una cuenta de servicio de CI/CD y descargar una clave JSON.
3. Para una práctica académica, conceder permisos suficientes para administrar Run, SQL, API Gateway, Artifact Registry, Build, IAM, Secret Manager, Storage y Logging. En producción se deben reducir al mínimo.
4. Crear los Secrets anteriores en GitHub.
5. Subir el repositorio y hacer `push` a `main`.

El workflow crea el bucket remoto `${GCP_PROJECT_ID}-terraform-state`, habilita APIs y crea primero Artifact Registry. Luego `gcloud builds submit` construye/publica la imagen; finalmente ejecuta `terraform plan`, `terraform apply -auto-approve` y `gcloud run deploy`.

## Configurar Flutter con la URL cloud

Copiar `api_gateway_url` del output de Terraform y agregar `/api`:

```bash
flutter run --dart-define=API_URL=https://HOST_DEL_GATEWAY/api
```

Para generar el APK conectado a GCP:

```bash
flutter build apk --release --dart-define=API_URL=https://HOST_DEL_GATEWAY/api
```

No hay que modificar `config.dart`: `String.fromEnvironment` selecciona la URL al compilar.

## Evidencias para el profesor

1. GitHub: repositorio, rama `main`, commits y `.github/workflows/deploy.yml`.
2. Actions: ejecución verde de Restore, Test, Build, Cloud Build, Terraform Plan/Apply y Deploy.
3. Terraform: `provider.tf`, `main.tf`, `variables.tf`, `outputs.tf`, `terraform.tfvars` y `terraform state list`.
4. GCP: Cloud Run, API Gateway, Artifact Registry, Cloud SQL, Secret Manager y Logs Explorer.
5. Mobile: login JWT, perfil, CRUD, dashboard concurrente y upload usando la URL del Gateway.

## Explicación oral corta

“Terraform crea la infraestructura de manera repetible. GitHub Actions se activa con cada push a main, prueba el backend y delega a Cloud Build la imagen Docker. Artifact Registry guarda esa imagen y Cloud Run la ejecuta de forma serverless. API Gateway expone una URL única y Cloud SQL conserva los datos PostgreSQL. Las credenciales no están en el código: GitHub Secrets las entrega al pipeline y Secret Manager las inyecta en Cloud Run.”

## Costos y limpieza

Cloud SQL genera costo aunque Cloud Run escale a cero. Después de la demostración:

```bash
cd terraform
terraform destroy
```

Revisar cuidadosamente el plan antes de confirmar la destrucción.
