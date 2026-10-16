using System.Text.Json;
using Google.Cloud.PubSub.V1;
using UserFlow.Api.DTOs;

namespace UserFlow.Api.Services;

// Publica el mensaje y termina. El correo lo envía otra Cloud Run.
public class NotificationPublisher(IConfiguration config)
{
    public async Task<string> PublishAsync(NotificationRequest request)
    {
        var project = config["GCP_PROJECT_ID"] ?? throw new InvalidOperationException("Falta GCP_PROJECT_ID.");
        var topic = config["PUBSUB_TOPIC_ID"] ?? throw new InvalidOperationException("Falta PUBSUB_TOPIC_ID.");
        var publisher = await PublisherClient.CreateAsync(TopicName.FromProjectTopic(project, topic));
        return await publisher.PublishAsync(JsonSerializer.Serialize(request));
    }
}
