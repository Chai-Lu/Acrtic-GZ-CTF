@echo off
echo Starting GZ::CTF Environment...

echo.
echo [1/3] Building Frontend...
cd src/GZCTF/ClientApp
call pnpm build
if %ERRORLEVEL% NEQ 0 (
    echo Frontend build failed!
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo [2/3] Deploying Frontend Assets...
cd ../../..
if not exist "src\GZCTF\wwwroot" mkdir "src\GZCTF\wwwroot"
xcopy /E /I /Y "src\GZCTF\ClientApp\build" "src\GZCTF\wwwroot"
if %ERRORLEVEL% NEQ 0 (
    echo Failed to copy frontend assets!
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo [3/3] Starting Backend (Aspire Host)...
dotnet run --project src/GZCTF.AppHost/GZCTF.AppHost.csproj

pause