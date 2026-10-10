namespace UserFlow.Api.Services;
public class FileStorageService(IWebHostEnvironment environment)
{
    public const long MaxBytes = 10 * 1024 * 1024;
    private static readonly HashSet<string> AllowedExtensions = [".jpg", ".jpeg", ".png", ".webp", ".pdf"];
    public async Task<(string Filename, string Url)> SaveAsync(IFormFile file, CancellationToken token)
    {
        var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
        if (file.Length == 0 || file.Length > MaxBytes) throw new ArgumentException("El archivo debe pesar entre 1 byte y 10 MB.");
        if (!AllowedExtensions.Contains(extension)) throw new ArgumentException("Solo se permiten JPG, PNG, WEBP y PDF.");
        if (!await HasValidSignatureAsync(file, extension, token)) throw new ArgumentException("El contenido no coincide con la extensión del archivo.");
        var filename = $"{Guid.NewGuid():N}{extension}";
        var folder = Path.Combine(environment.ContentRootPath, "uploads");
        Directory.CreateDirectory(folder);
        await using var stream = File.Create(Path.Combine(folder, filename));
        await file.CopyToAsync(stream, token);
        return (filename, $"/uploads/{filename}");
    }
    private static async Task<bool> HasValidSignatureAsync(IFormFile file, string extension, CancellationToken token)
    {
        var header = new byte[12];
        await using var input = file.OpenReadStream();
        var read = await input.ReadAsync(header, token);
        bool Starts(params byte[] bytes) => read >= bytes.Length && header.AsSpan(0, bytes.Length).SequenceEqual(bytes);
        return extension switch
        {
            ".pdf" => Starts(0x25, 0x50, 0x44, 0x46),
            ".png" => Starts(0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A),
            ".jpg" or ".jpeg" => Starts(0xFF, 0xD8, 0xFF),
            ".webp" => read >= 12 && header.AsSpan(0, 4).SequenceEqual("RIFF"u8) && header.AsSpan(8, 4).SequenceEqual("WEBP"u8),
            _ => false
        };
    }
    public void Delete(string filename)
    {
        var path = Path.Combine(environment.ContentRootPath, "uploads", Path.GetFileName(filename));
        if (File.Exists(path)) File.Delete(path);
    }
}
