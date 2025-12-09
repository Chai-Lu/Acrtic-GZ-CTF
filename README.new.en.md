# Acrtic-GZ-CTF

[Ori-English](./README.en.md) | [源-简体中文](./README.zh.md) | [源-日本語](./README.ja.md)
[简体中文](./README.md)

This is a customized GZ::CTF platform environment.

##  Quick Start

Two startup scripts are provided for different scenarios:

### 1. `start_env.bat` (Recommended for Demo/Preview)
*   **Logic**: Builds frontend first, then starts backend.
*   **Features**: Simulates production environment (backend hosts static frontend files). No extra frontend service required after start. Does not support frontend hot-reload.
*   **Usage**: `.\start_env.bat`

### 2. `start_dev.bat` (Recommended for Development)
*   **Logic**: Environment check + Certificate setup + Dependency install + Start backend.
*   **Features**: Automatically configures HTTPS dev certificates and installs frontend dependencies. Suitable for first-time setup or active development (used with IDE).
*   **Usage**: `.\start_dev.bat`

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

### Local Testing

You can test the generated Release package directly on your local machine without affecting the existing Git repository code.

**Using Presets (Using Saves):**
For quick local testing, the `Further-TBD/saves/` directory contains a set of preset configuration files (`appsettings.json` and `docker-compose.yml`) with passwords configured for local testing.
*   This directory is ignored by Git (except for `.gitkeep`), so you can safely store your own test configurations here.
*   **Usage**: After generating the Release, copy all files from the `saves` directory to the `release` directory, overwriting the existing ones.

**Testing Steps:**

1.  **Stop Dev Environment**: If `start_env.bat` or other services using port 8080 are running, stop them first.
2.  **Apply Config**: Copy configuration files from `Further-TBD/saves/` to `Further-TBD/release/`.
3.  **Start Release**:
    ```powershell
    cd Further-TBD/release
    # If generated via local mode and image exists locally, skip the load step
    docker-compose up -d
    ```
4.  **Access**: Open `http://localhost:8080` in your browser.
5.  **Cleanup**: After testing, stop and remove the containers:
    ```powershell
    docker-compose down
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
