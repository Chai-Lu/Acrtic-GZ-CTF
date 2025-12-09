# Acrtic-GZ-CTF

[Ori-English](./README.en.md) | [源-简体中文](./README.zh.md) | [源-日本語](./README.ja.md)
[简体中文](./README.md)

This is a customized GZ::CTF platform environment.

##  Quick Start

To start the development environment with one click, simply run the provided batch script:

### `start_env.bat`

This script automates the following steps:
1.  **Builds the Frontend**: Compiles the React application in `src/GZCTF/ClientApp`.
2.  **Deploys Assets**: Copies the build artifacts to the backend's `wwwroot` directory.
3.  **Starts the Backend**: Launches the .NET Aspire AppHost (`GZCTF.AppHost`), which orchestrates the GZ::CTF server, PostgreSQL database, Redis cache, and MinIO storage.

**Usage:**
Double-click `start_env.bat` or run it from the command line:
```powershell
.\start_env.bat
```

---

##  Release Generation

If you need to generate a standalone package for production deployment (including Docker configuration), use the release generation script.

### Release Scripts

Located in `Further-TBD/`, three generation methods are provided:

1.  **`generate_release_network.ps1` (Recommended)**
    *   **Scenario**: Good network environment, Docker container can access GitHub.
    *   **Function**: Standard build process, automatically downloads `Satori` dependency during Docker build.
    *   **Usage**: `.\generate_release_network.ps1`

2.  **`generate_release_local.ps1` (Offline/Restricted Network)**
    *   **Scenario**: Restricted network inside Docker container, unable to download dependencies.
    *   **Function**: Uses locally pre-downloaded dependency files.
    *   **Prerequisite**: Manually download `linux_musl_amd64.zip` (or `arm64`) and place it in `Further-TBD/locallybuild/`.
    *   **Usage**: `.\generate_release_local.ps1`

3.  **`app.ps1` (Legacy)**
    *   **Scenario**: Requires legacy directory structure (`release/app`).
    *   **Function**: Generates legacy deployment structure.
    *   **Usage**: `.\app.ps1`

### Release Package Structure

The generated `release` directory is a complete offline deployment package containing:
*   `images/gzctf.tar`: Offline Docker image containing the full application and dependencies.
*   `docker-compose.yml`: Service orchestration file.
*   `appsettings.json`: Application configuration file.
*   `version.md`: Version information.
*   `data/`: Pre-created data mount directories.

**General Usage:**
```powershell
cd Further-TBD
.\generate_release_local.ps1 # Example
# Enter the version number when prompted, or press Enter to use the default
```

**Deployment:**

Send the generated `release` directory to the deployment personnel and run the following on the target machine:
```powershell
cd release
# 1. Load offline image
docker load -i images/gzctf.tar
# 2. Start services
docker-compose up -d
```

---

##  Backup & Recovery

For detailed instructions on data persistence, please refer to [Further-TBD/RECOVERY.MD](Further-TBD/RECOVERY.MD).

### Summary

#### Backup
- **Database**: Use `pg_dump` to export the PostgreSQL database.
- **Files**: Archive the `files` directory (attachments, images).
- **Config**: Backup `docker-compose.yml` and `appsettings.json`.

#### Recovery
1.  **Restore Files**: Extract the file archive to the mapped volume directory.
2.  **Start Database**: Launch the database container.
3.  **Import Data**: Use `psql` to import the SQL dump.
4.  **Start Application**: Launch the full stack.

For the complete guide, see the [Recovery Documentation](Further-TBD/RECOVERY.MD).
