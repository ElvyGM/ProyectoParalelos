using System.Net;
using System.Net.Mail;
using System.Text;
using System.Text.Json;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/health", () => Results.Ok(new { status = "ok" }));

// Pub/Sub envía un sobre JSON y el mensaje real viene codificado en Base64.
app.MapPost("/pubsub/push", async (PubSubEnvelope envelope, IConfiguration config, ILogger<Program> log) =>
{
    try
    {
        var json = Encoding.UTF8.GetString(Convert.FromBase64String(envelope.Message.Data));
        var email = JsonSerializer.Deserialize<EmailMessage>(json, new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        }) ?? throw new InvalidOperationException("Mensaje vacío.");

        // Google muestra las contraseñas de aplicación en grupos con espacios.
        // SMTP necesita únicamente los 16 caracteres.
        var smtpPassword = string.Concat((config["SMTP_PASSWORD"] ?? "")
            .Where(c => !char.IsWhiteSpace(c)));
        using var smtp = new SmtpClient(config["SMTP_HOST"], int.Parse(config["SMTP_PORT"] ?? "587"))
        {
            EnableSsl = true,
            Credentials = new NetworkCredential(config["SMTP_USER"], smtpPassword)
        };
        using var mail = new MailMessage(config["SMTP_USER"]!, email.Email, email.Subject, email.Message);
        await smtp.SendMailAsync(mail);
        log.LogInformation("Correo {MessageId} enviado a {Email}", envelope.Message.MessageId, email.Email);
        return Results.NoContent();
    }
    catch (Exception ex)
    {
        log.LogError(ex, "No se pudo procesar el mensaje {MessageId}", envelope.Message.MessageId);
        return Results.StatusCode(500); // Pub/Sub volverá a intentarlo.
    }
});

app.Run();

record PubSubEnvelope(PubSubMessage Message);
record PubSubMessage(string Data, string MessageId);
record EmailMessage(string Email, string Subject, string Message);

public partial class Program { }
