using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using UserFlow.Api.Data;
using UserFlow.Api.DTOs;
namespace UserFlow.Api.Controllers;

[ApiController, Authorize]
public class DashboardController(AppDbContext db) : ControllerBase
{
    private int CurrentUserId => int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
    [HttpGet("api/profile")]
    public async Task<ActionResult<UserResponse>> Profile()
    {
        var user = await db.Users.FindAsync(CurrentUserId);
        return user is null ? NotFound() : Ok(user.ToResponse());
    }
    [HttpGet("api/stats")]
    public async Task<IActionResult> Stats() => Ok(new { users = await db.Users.CountAsync(), files = await db.Files.CountAsync(), myFiles = await db.Files.CountAsync(x => x.UserId == CurrentUserId), generatedAt = DateTime.UtcNow });
    [HttpGet("api/notifications")]
    public IActionResult Notifications() => Ok(new[] { new { id = 1, title = "Bienvenido a UserFlow", read = false }, new { id = 2, title = "Prueba la carga concurrente", read = false } });
}
