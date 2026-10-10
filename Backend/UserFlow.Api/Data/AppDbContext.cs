using Microsoft.EntityFrameworkCore;
using UserFlow.Api.Models;
namespace UserFlow.Api.Data;
public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<User> Users => Set<User>();
    public DbSet<FileRecord> Files => Set<FileRecord>();
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<User>().HasIndex(x => x.Email).IsUnique();
        modelBuilder.Entity<FileRecord>().HasOne(x => x.User).WithMany(x => x.Files).HasForeignKey(x => x.UserId).OnDelete(DeleteBehavior.Cascade);
    }
}
