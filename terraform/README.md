# Terraform mínimo de UserFlow

Los archivos se dividen así:

- `provider.tf`: proveedor Google y estado remoto.
- `variables.tf`: datos que cambian entre cuentas.
- `main.tf`: infraestructura de la API original.
- `notifications.tf`: Pub/Sub y Cloud Run de correos.
- `outputs.tf`: direcciones y nombres que se muestran al terminar.

El pipeline ejecuta automáticamente `init`, `validate`, `plan` y `apply`. Para practicar localmente sin crear recursos:

```cmd
cd /d "C:\Users\elvis\OneDrive\Documentos\Proyecto-Elvy\terraform"
terraform fmt -check
terraform validate
```

Para desplegar se necesitan los secretos de GitHub anteriores y también `SMTP_USER` y `SMTP_PASSWORD`. No escriba contraseñas reales en `terraform.tfvars`.

## Cómo explicarlo

`resource` declara algo que GCP debe crear. Una referencia como `google_pubsub_topic.notifications.id` conecta dos recursos sin copiar nombres. `depends_on` obliga un orden únicamente cuando Terraform no puede deducirlo. Las variables evitan fijar credenciales y nombres en el código; los outputs muestran el resultado del despliegue.
