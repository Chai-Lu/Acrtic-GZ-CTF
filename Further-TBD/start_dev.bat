@echo off
setlocal enabledelayedexpansion

echo ========================================================
echo       GZCTF Local Development Environment Launcher
echo ========================================================

:: Check for Administrator privileges
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [INFO] Running with Administrator privileges.
) else (
    echo [WARN] Not running as Administrator. 
    echo [WARN] 'dotnet dev-certs https --trust' might fail or prompt for elevation.
)

echo.
echo [STEP 1] Checking HTTPS Development Certificates...
echo --------------------------------------------------------
echo [INFO] Cleaning old certificates...
dotnet dev-certs https --clean
echo [INFO] Trusting new certificate...
dotnet dev-certs https --trust
if %errorLevel% neq 0 (
    echo [ERROR] Failed to trust development certificate.
    echo [TIP] Try running this script as Administrator.
    pause
    exit /b 1
) else (
    echo [SUCCESS] HTTPS certificate is trusted.
)

echo.
echo [STEP 2] Checking Frontend Environment (pnpm)...
echo --------------------------------------------------------
where pnpm >nul 2>&1
if %errorLevel% neq 0 (
    echo [INFO] pnpm not found. Installing via npm...
    npm install -g pnpm
    if !errorLevel! neq 0 (
        echo [ERROR] Failed to install pnpm. Please install Node.js and npm first.
        pause
        exit /b 1
    )
    echo [SUCCESS] pnpm installed.
) else (
    echo [SUCCESS] pnpm is already installed.
)

echo.
echo [STEP 3] Installing Frontend Dependencies...
echo --------------------------------------------------------
cd src\GZCTF\ClientApp
call pnpm install
if %errorLevel% neq 0 (
    echo [ERROR] Failed to install frontend dependencies.
    pause
    exit /b 1
)
cd ..\..\..
echo [SUCCESS] Frontend dependencies installed.

echo.
echo [STEP 4] Starting GZCTF Platform (Backend + Infrastructure)...
echo --------------------------------------------------------
echo [INFO] This will start Docker containers for Postgres, Redis, and MinIO.
echo [INFO] Press Ctrl+C to stop the server.
echo.

dotnet run --project src/GZCTF.AppHost/GZCTF.AppHost.csproj

pause
