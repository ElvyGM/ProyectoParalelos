using System.ComponentModel.DataAnnotations;
namespace UserFlow.Api.DTOs;
public record RegisterDto([Required, MaxLength(80)] string Nombre, [Required, MaxLength(80)] string Apellido, [Required, EmailAddress] string Email, [Required, MinLength(6)] string Password);
public record LoginDto([Required, EmailAddress] string Email, [Required] string Password);
public record UserCreateDto([Required, MaxLength(80)] string Nombre, [Required, MaxLength(80)] string Apellido, [Required, EmailAddress] string Email, [Required, MinLength(6)] string Password, string? Foto);
public record UserUpdateDto([Required, MaxLength(80)] string Nombre, [Required, MaxLength(80)] string Apellido, [Required, EmailAddress] string Email, [MinLength(6)] string? Password, string? Foto);
public record UserResponse(int Id, string Nombre, string Apellido, string Email, string? Foto, DateTime CreatedAt);
public record AuthResponse(string Token, DateTime ExpiresAt, UserResponse User);
public record FileResponse(int Id, string Filename, string OriginalName, string ContentType, long Size, string Url, int UserId, DateTime CreatedAt);
public static class DtoMappings
{
    public static UserResponse ToResponse(this Models.User x) => new(x.Id, x.Nombre, x.Apellido, x.Email, x.Foto, x.CreatedAt);
    public static FileResponse ToResponse(this Models.FileRecord x) => new(x.Id, x.Filename, x.OriginalName, x.ContentType, x.Size, x.Url, x.UserId, x.CreatedAt);
}
