# Acrtic-GZ-CTF

[Ori-English](./README.en.md) | [源-简体中文](./README.zh.md) | [源-日本語](./README.ja.md)
[简体中文](./README.md)

This is a customized GZ::CTF platform environment.

## 🚀 Quick Start

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

## 🛡️ Backup & Recovery

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
