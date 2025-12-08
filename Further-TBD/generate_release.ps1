$ErrorActionPreference = "Stop"

# Configuration
$InputVersion = Read-Host "Enter version (default: 1.7.2)"
if ([string]::IsNullOrWhiteSpace($InputVersion)) {
    $InputVersion = "1.7.2"
}
$Version = "v$InputVersion-arctic"

$ReleaseDir = Join-Path $PSScriptRoot "release"
$SourceDir = Join-Path $PSScriptRoot "..\src\GZCTF"
$TempBuildDir = Join-Path $PSScriptRoot "temp_build"

# Get Git Info
try {
    $CommitHash = git rev-parse HEAD
    $ShortHash = git rev-parse --short HEAD
} catch {
    Write-Warning "Git not found or not a git repo. Using placeholders."
    $CommitHash = "0000000000000000000000000000000000000000"
    $ShortHash = "0000000"
}

$Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssK"

Write-Host "Generating release for version: $Version ($ShortHash)"
Write-Host "Build Time: $Timestamp"

# Set Environment Variables for Build
$env:VITE_APP_GIT_NAME = $Version
$env:VITE_APP_GIT_SHA = $CommitHash
$env:VITE_APP_BUILD_TIMESTAMP = $Timestamp

# Clean and Create Release Directory
if (Test-Path $ReleaseDir) {
    Remove-Item -Path $ReleaseDir -Recurse -Force
}
New-Item -Path $ReleaseDir -ItemType Directory | Out-Null
New-Item -Path "$ReleaseDir\data" -ItemType Directory | Out-Null
New-Item -Path "$ReleaseDir\data\files" -ItemType Directory | Out-Null
New-Item -Path "$ReleaseDir\data\db" -ItemType Directory | Out-Null

# Clean and Create Temp Build Directory
if (Test-Path $TempBuildDir) {
    Remove-Item -Path $TempBuildDir -Recurse -Force
}
New-Item -Path $TempBuildDir -ItemType Directory | Out-Null

# Publish Backend (triggers Frontend build)
Write-Host "Building and Publishing to temp directory..."
dotnet publish "$SourceDir\GZCTF.csproj" -c Release -o "$TempBuildDir\publish" /p:VITE_APP_GIT_NAME=$Version /p:VITE_APP_GIT_SHA=$CommitHash /p:VITE_APP_BUILD_TIMESTAMP=$Timestamp

# Copy Dockerfile to temp build dir
Copy-Item "$SourceDir\Dockerfile" "$TempBuildDir\Dockerfile"

# Build Docker Image
Write-Host "Building Docker Image (gzctf:latest)..."
try {
    docker build -t gzctf:latest "$TempBuildDir"
} catch {
    Write-Error "Docker build failed. Please ensure Docker is running."
    exit 1
}

# Remove Temp Build Directory
Remove-Item -Path $TempBuildDir -Recurse -Force

# Generate version.md
$VersionContent = @"
$Version #$ShortHash
Built at $Timestamp

Copyright © 2022-now @GZTimeWalker
"@
$VersionContent | Out-File "$ReleaseDir\version.md" -Encoding utf8

# Generate appsettings.json
$AppSettings = @{
    "AllowedHosts" = "*"
    "ConnectionStrings" = @{
        "Database" = "Host=db;Database=gzctf;Username=postgres;Password=GZCTF_POSTGRES_PASSWORD"
        "RedisCache" = "redis:6379,password=GZCTF_REDIS_PASSWORD"
        "Storage" = "disk://path=./files"
    }
    "Logging" = @{
        "LogLevel" = @{
            "Default" = "Information"
            "Microsoft.AspNetCore" = "Warning"
        }
    }
    "Kestrel" = @{
        "Endpoints" = @{
            "Http" = @{
                "Url" = "http://*:8080"
            }
        }
    }
}
$AppSettings | ConvertTo-Json -Depth 10 | Out-File "$ReleaseDir\appsettings.json" -Encoding utf8

# Generate docker-compose.yml
$DockerCompose = @"
services:
  gzctf:
    image: gzctf:latest
    restart: always
    ports:
      - "80:8080"
    environment:
      - GZCTF_ADMIN_PASSWORD=admin
      # - GZCTF_ConnectionStrings__Database=Host=db;Database=gzctf;Username=postgres;Password=change_this_password
      # - GZCTF_ConnectionStrings__RedisCache=redis:6379,password=change_this_password
    volumes:
      - ./appsettings.json:/app/appsettings.json:ro
      - ./data/files:/app/files
      - /var/run/docker.sock:/var/run/docker.sock
    depends_on:
      - db
      - redis

  db:
    image: postgres:16-alpine
    restart: always
    environment:
      - POSTGRES_PASSWORD=GZCTF_POSTGRES_PASSWORD
      - POSTGRES_DB=gzctf
    volumes:
      - ./data/db:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    restart: always
    command: redis-server --requirepass GZCTF_REDIS_PASSWORD

"@
$DockerCompose | Out-File "$ReleaseDir\docker-compose.yml" -Encoding utf8

Write-Host "Release generated in $ReleaseDir"
Write-Host "Docker image 'gzctf:latest' has been built locally."
Write-Host "To run the services:"
Write-Host "  cd $ReleaseDir"
Write-Host "  docker-compose up -d"

