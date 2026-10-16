using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.Extensions.FileProviders;
using Microsoft.OpenApi;
using UserFlow.Api.Data;
using UserFlow.Api.Services;

var builder = WebApplication.CreateBuilder(args);
// En local se usan appsettings/variables __. En Cloud Run, Secret Manager
// inyecta los nombres simples solicitados por la asignación.
var jwtKey = builder.Configuration["JWT_SECRET"]
    ?? builder.Configuration["Jwt:Key"]
    ?? throw new InvalidOperationException("Configure JWT_SECRET o Jwt:Key.");
var databaseUrl = builder.Configuration["DATABASE_URL"]
    ?? builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Configure DATABASE_URL o ConnectionStrings:DefaultConnection.");
builder.Services.AddControllers();
builder.Services.AddOpenApi();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo { Title = "UserFlow API - Elvy Grullón", Version = "v1" });
    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Type = SecuritySchemeType.Http, Scheme = "bearer", BearerFormat = "JWT",
        Description = "Introduzca el token JWT."
    });
    options.AddSecurityRequirement(document => new OpenApiSecurityRequirement
    {
        [new OpenApiSecuritySchemeReference("Bearer", document)] = []
    });
});
builder.Services.AddDbContext<AppDbContext>(options => options.UseNpgsql(databaseUrl));
builder.Services.AddScoped<JwtService>();
builder.Services.AddScoped<FileStorageService>();
builder.Services.AddSingleton<NotificationPublisher>();
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme).AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true, ValidateAudience = true, ValidateLifetime = true, ValidateIssuerSigningKey = true,
        ValidIssuer = builder.Configuration["Jwt:Issuer"] ?? "UserFlow.Api",
        ValidAudience = builder.Configuration["Jwt:Audience"] ?? "UserFlow.Mobile",
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)), ClockSkew = TimeSpan.FromSeconds(10)
    };
});
builder.Services.AddAuthorization();
builder.Services.AddCors(options => options.AddPolicy("Mobile", policy => policy.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod()));

var app = builder.Build();
Directory.CreateDirectory(Path.Combine(app.Environment.ContentRootPath, "uploads"));
app.UseSwagger();
app.UseSwaggerUI();
app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(Path.Combine(app.Environment.ContentRootPath, "uploads")),
    RequestPath = "/uploads"
});
app.UseCors("Mobile");
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.MapGet("/health", () => Results.Ok(new { status = "ok", utc = DateTime.UtcNow }));
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    await db.Database.EnsureCreatedAsync();
}
app.Run();
public partial class Program { }
