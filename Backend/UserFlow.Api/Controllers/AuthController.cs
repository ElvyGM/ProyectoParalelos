using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using UserFlow.Api.Data;
using UserFlow.Api.DTOs;
using UserFlow.Api.Models;
using UserFlow.Api.Services;
namespace UserFlow.Api.Controllers;

[ApiController, Route("api/auth")]
public class AuthController(AppDbContext db, JwtService jwt) : ControllerBase
{
    [HttpPost("register")]
    public async Task<ActionResult<AuthResponse>> Register(RegisterDto dto)
    {
        var email = dto.Email.Trim().ToLowerInvariant();
        if (await db.Users.AnyAsync(x => x.Email == email)) return Conflict(new { message = "El correo ya está registrado." });
        var user = new User { Nombre = dto.Nombre.Trim(), Apellido = dto.Apellido.Trim(), Email = email, PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password, 12) };
        db.Users.Add(user);
        await db.SaveChangesAsync();
        var (token, expires) = jwt.Create(user);
        return Created("/api/profile", new AuthResponse(token, expires, user.ToResponse()));
    }

    [HttpPost("login")]
    public async Task<ActionResult<AuthResponse>> Login(LoginDto dto)
    {
        var user = await db.Users.SingleOrDefaultAsync(x => x.Email == dto.Email.Trim().ToLowerInvariant());
        if (user is null || !BCrypt.Net.BCrypt.Verify(dto.Password, user.PasswordHash)) return Unauthorized(new { message = "Correo o contraseña incorrectos." });
        var (token, expires) = jwt.Create(user);
        return Ok(new AuthResponse(token, expires, user.ToResponse()));
    }
}
