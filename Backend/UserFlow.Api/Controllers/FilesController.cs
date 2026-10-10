using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using UserFlow.Api.Data;
using UserFlow.Api.DTOs;
using UserFlow.Api.Models;
using UserFlow.Api.Services;
namespace UserFlow.Api.Controllers;

[ApiController, Route("api"), Authorize]
public class FilesController(AppDbContext db, FileStorageService storage) : ControllerBase
{
    private int CurrentUserId => int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
    [HttpGet("files")]
    public async Task<ActionResult<IEnumerable<FileResponse>>> List() => Ok(await db.Files.AsNoTracking().OrderByDescending(x => x.Id).Select(x => new FileResponse(x.Id, x.Filename, x.OriginalName, x.ContentType, x.Size, x.Url, x.UserId, x.CreatedAt)).ToListAsync());

    [HttpPost("upload"), RequestSizeLimit(FileStorageService.MaxBytes)]
    public async Task<ActionResult<FileResponse>> Upload(IFormFile file, CancellationToken token)
    {
        try
        {
            var saved = await storage.SaveAsync(file, token);
            var record = new FileRecord { Filename = saved.Filename, OriginalName = Path.GetFileName(file.FileName), ContentType = file.ContentType, Size = file.Length, Url = saved.Url, UserId = CurrentUserId };
            db.Files.Add(record); await db.SaveChangesAsync(token);
            return Created(saved.Url, record.ToResponse());
        }
        catch (ArgumentException ex) { return BadRequest(new { message = ex.Message }); }
    }

    [HttpDelete("upload/{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var record = await db.Files.FindAsync(id);
        if (record is null) return NotFound(new { message = "Archivo no encontrado." });
        if (record.UserId != CurrentUserId) return Forbid();
        storage.Delete(record.Filename); db.Files.Remove(record); await db.SaveChangesAsync(); return NoContent();
    }
}
