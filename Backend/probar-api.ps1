$ErrorActionPreference = 'Stop'
$base = 'http://localhost:8080'
$email = "elvy.$([DateTimeOffset]::UtcNow.ToUnixTimeSeconds())@example.com"
$body = @{ nombre='Elvy Antonio'; apellido='Grullón Morel'; email=$email; password='123456' } | ConvertTo-Json
$auth = Invoke-RestMethod -Method Post -Uri "$base/api/auth/register" -ContentType 'application/json' -Body $body
$headers = @{ Authorization = "Bearer $($auth.token)" }
$users = Invoke-RestMethod -Uri "$base/api/users" -Headers $headers
$profile = Invoke-RestMethod -Uri "$base/api/profile" -Headers $headers
$stats = Invoke-RestMethod -Uri "$base/api/stats" -Headers $headers
$withoutToken = try { Invoke-WebRequest -Uri "$base/api/users" -SkipHttpErrorCheck } catch { $_.Exception.Response }
$testFile = Join-Path $PSScriptRoot 'test-file.pdf'
$uploaded = Invoke-RestMethod -Method Post -Uri "$base/api/upload" -Headers $headers -Form @{ file = Get-Item $testFile }
Invoke-RestMethod -Method Delete -Uri "$base/api/upload/$($uploaded.id)" -Headers $headers
[pscustomobject]@{
  Health = (Invoke-RestMethod -Uri "$base/health").status
  JwtReceived = -not [string]::IsNullOrWhiteSpace($auth.token)
  ProtectedUsers = @($users).Count
  Profile = "$($profile.nombre) $($profile.apellido)"
  StatsUsers = $stats.users
  WithoutTokenStatus = [int]$withoutToken.StatusCode
  UploadCreated = -not [string]::IsNullOrWhiteSpace($uploaded.filename)
  UploadDeleted = $true
} | Format-List
