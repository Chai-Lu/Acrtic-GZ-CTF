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

# Generate Dockerfile for local build (Dynamic Satori download inside Docker)
$DockerfileContent = @"
FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine AS final

# Install dependencies
RUN apk add --update --no-cache wget libpcap icu-data-full icu-libs \
    ca-certificates libgdiplus tzdata krb5-libs unzip && \
    update-ca-certificates

# Download Satori (Dynamic based on arch, defaulting to amd64)
ARG TARGETARCH
RUN if [ -z "`$TARGETARCH" ]; then TARGETARCH=amd64; fi && \
    echo "Building for architecture: `$TARGETARCH" && \
    wget -O satori.zip "https://github.com/hez2010/Satori/releases/latest/download/linux_musl_`$TARGETARCH.zip" && \
    unzip satori.zip -d satori && \
    chmod +x satori/* && \
    mv satori/* /usr/share/dotnet/shared/Microsoft.NETCore.App/`$(ls /usr/share/dotnet/shared/Microsoft.NETCore.App)/ && \
    rm satori.zip && rm -rf satori

ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false \
    LC_ALL=en_US.UTF-8

WORKDIR /app
COPY --chown=`$APP_UID:`$APP_UID publish .

EXPOSE 8080

HEALTHCHECK --interval=5m --timeout=3s --start-period=10s --retries=1 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/healthz || exit 1

ENTRYPOINT ["dotnet", "GZCTF.dll"]
"@
$DockerfileContent | Out-File "$TempBuildDir\Dockerfile" -Encoding utf8

# Build Docker Image
Write-Host "Building Docker Image (gzctf:latest)..."
docker build -t gzctf:latest "$TempBuildDir"
if ($LASTEXITCODE -ne 0) {
    Write-Error "Docker build failed. Please check your network connection to mcr.microsoft.com or configure a proxy."
    if (Test-Path $TempBuildDir) {
        Remove-Item -Path $TempBuildDir -Recurse -Force
    }
    exit 1
}

# Export Docker Image
Write-Host "Exporting Docker Image to tarball..."
New-Item -Path "$ReleaseDir\images" -ItemType Directory | Out-Null
docker save -o "$ReleaseDir\images\gzctf.tar" gzctf:latest

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
    "XorKey" = "GZCTF_XOR_KEY_PLACEHOLDER"
    "Logging" = @{
        "LogLevel" = @{
            "Default" = "Information"
            "Microsoft.AspNetCore" = "Warning"
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
Write-Host "Docker image exported to 'images/gzctf.tar'."
Write-Host "To run the services:"
Write-Host "  cd $ReleaseDir"
Write-Host "  docker load -i images/gzctf.tar"
Write-Host "  docker-compose up -d"

