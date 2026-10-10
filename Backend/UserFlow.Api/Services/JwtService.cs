using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;
using UserFlow.Api.Models;
namespace UserFlow.Api.Services;
public class JwtService(IConfiguration configuration)
{
    public (string Token, DateTime ExpiresAt) Create(User user)
    {
        var expiresAt = DateTime.UtcNow.AddHours(2);
        Claim[] claims = [new(JwtRegisteredClaimNames.Sub, user.Id.ToString()), new(JwtRegisteredClaimNames.Email, user.Email), new(ClaimTypes.NameIdentifier, user.Id.ToString()), new(ClaimTypes.Name, $"{user.Nombre} {user.Apellido}")];
        // En Cloud Run se usa JWT_SECRET; en desarrollo local se conserva Jwt:Key.
        var jwtKey = configuration["JWT_SECRET"]
            ?? configuration["Jwt:Key"]
            ?? throw new InvalidOperationException("Configure JWT_SECRET o Jwt:Key.");
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey));
        var token = new JwtSecurityToken(configuration["Jwt:Issuer"], configuration["Jwt:Audience"], claims, expires: expiresAt, signingCredentials: new SigningCredentials(key, SecurityAlgorithms.HmacSha256));
        return (new JwtSecurityTokenHandler().WriteToken(token), expiresAt);
    }
}
