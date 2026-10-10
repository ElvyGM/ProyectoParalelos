using System.ComponentModel.DataAnnotations;
namespace UserFlow.Api.Models;
public class User
{
    public int Id { get; set; }
    [MaxLength(80)] public required string Nombre { get; set; }
    [MaxLength(80)] public required string Apellido { get; set; }
    [MaxLength(180)] public required string Email { get; set; }
    public required string PasswordHash { get; set; }
    [MaxLength(500)] public string? Foto { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public List<FileRecord> Files { get; set; } = [];
}
