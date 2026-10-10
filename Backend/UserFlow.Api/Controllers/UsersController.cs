using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using UserFlow.Api.Data;
using UserFlow.Api.DTOs;
using UserFlow.Api.Models;
namespace UserFlow.Api.Controllers;

[ApiController, Route("api/users"), Authorize]
public class UsersController(AppDbContext db) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<IEnumerable<UserResponse>>> GetAll() => Ok(await db.Users.AsNoTracking().OrderBy(x => x.Id).Select(x => new UserResponse(x.Id, x.Nombre, x.Apellido, x.Email, x.Foto, x.CreatedAt)).ToListAsync());

    [HttpGet("{id:int}")]
    public async Task<ActionResult<UserResponse>> GetById(int id)
    {
        var user = await db.Users.FindAsync(id);
        return user is null ? NotFound(new { message = "Usuario no encontrado." }) : Ok(user.ToResponse());
    }

    [HttpPost]
    public async Task<ActionResult<UserResponse>> Create(UserCreateDto dto)
    {
        var email = dto.Email.Trim().ToLowerInvariant();
        if (await db.Users.AnyAsync(x => x.Email == email)) return Conflict(new { message = "El correo ya existe." });
        var user = new User { Nombre = dto.Nombre.Trim(), Apellido = dto.Apellido.Trim(), Email = email, PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password, 12), Foto = dto.Foto };
        db.Users.Add(user); await db.SaveChangesAsync();
        return CreatedAtAction(nameof(GetById), new { id = user.Id }, user.ToResponse());
    }

    [HttpPut("{id:int}")]
    public async Task<ActionResult<UserResponse>> Update(int id, UserUpdateDto dto)
    {
        var user = await db.Users.FindAsync(id);
        if (user is null) return NotFound(new { message = "Usuario no encontrado." });
        var email = dto.Email.Trim().ToLowerInvariant();
        if (await db.Users.AnyAsync(x => x.Email == email && x.Id != id)) return Conflict(new { message = "El correo ya existe." });
        user.Nombre = dto.Nombre.Trim(); user.Apellido = dto.Apellido.Trim(); user.Email = email; user.Foto = dto.Foto;
        if (!string.IsNullOrWhiteSpace(dto.Password)) user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password, 12);
        await db.SaveChangesAsync(); return Ok(user.ToResponse());
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var user = await db.Users.FindAsync(id);
        if (user is null) return NotFound(new { message = "Usuario no encontrado." });
        db.Users.Remove(user); await db.SaveChangesAsync(); return NoContent();
    }
}
