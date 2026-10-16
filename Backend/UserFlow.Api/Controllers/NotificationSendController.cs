using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using UserFlow.Api.DTOs;
using UserFlow.Api.Services;

namespace UserFlow.Api.Controllers;

[ApiController, Route("api/notifications"), Authorize]
public class NotificationSendController(NotificationPublisher publisher) : ControllerBase
{
    [HttpPost("send")]
    public async Task<IActionResult> Send(NotificationRequest request)
    {
        var messageId = await publisher.PublishAsync(request);
        return Accepted(new { message = "Mensaje publicado correctamente.", messageId });
    }
}
