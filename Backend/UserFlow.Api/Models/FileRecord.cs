using System.ComponentModel.DataAnnotations;
namespace UserFlow.Api.Models;
public class FileRecord
{
    public int Id { get; set; }
    [MaxLength(255)] public required string Filename { get; set; }
    [MaxLength(255)] public required string OriginalName { get; set; }
    [MaxLength(120)] public required string ContentType { get; set; }
    public long Size { get; set; }
    [MaxLength(500)] public required string Url { get; set; }
    public int UserId { get; set; }
    public User? User { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
