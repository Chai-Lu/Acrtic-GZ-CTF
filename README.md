# Acrtic-GZ-CTF

[Ori-English](./README.en.md) | [源-简体中文](./README.zh.md) | [源-日本語](./README.ja.md)
[English](./README.new.en.md)

这是一个定制化的 GZ::CTF 平台环境。

## 🚀 快速开始 (Quick Start)

要一键启动开发环境，只需运行提供的批处理脚本：

### `start_env.bat`

该脚本自动执行以下步骤：
1.  **构建前端**：编译 `src/GZCTF/ClientApp` 中的 React 应用程序。
2.  **部署资源**：将构建产物复制到后端的 `wwwroot` 目录。
3.  **启动后端**：启动 .NET Aspire AppHost (`GZCTF.AppHost`)，它负责编排 GZ::CTF 服务器、PostgreSQL 数据库、Redis 缓存和 MinIO 存储。

**用法：**
双击 `start_env.bat` 或在命令行中运行：
```powershell
.\start_env.bat
```

---

## � 发布生成 (Release Generation)

如果你需要生成用于生产环境部署的独立包（包含 Docker 配置），可以使用发布生成脚本。

### `Further-TBD/generate_release.ps1`

该脚本执行以下操作：
1.  **版本控制**：提示输入版本号（默认为 `1.7.2`，生成 `v1.7.2-arctic`），并自动获取 Git Commit Hash。
2.  **编译发布**：构建后端和前端，并将版本信息注入到应用中。
3.  **生成配置**：自动生成配套的 `docker-compose.yml` 和 `appsettings.json`。
4.  **打包输出**：所有文件将输出到 `Further-TBD/release` 目录。

**用法：**
```powershell
cd Further-TBD
.\generate_release.ps1
# 按提示输入版本号，或直接回车使用默认值
```

生成后，进入 `release` 目录即可使用 Docker Compose 启动：
```powershell
cd release
docker-compose up -d --build
```

---

## �🛡️ 备份与恢复 (Backup & Recovery)

有关数据持久化的详细说明，请参阅 [Further-TBD/RECOVERY.MD](Further-TBD/RECOVERY.MD)。

### 摘要

#### 备份 (Backup)
- **数据库**：使用 `pg_dump` 导出 PostgreSQL 数据库。
- **文件**：归档 `files` 目录（附件、图片）。
- **配置**：备份 `docker-compose.yml` 和 `appsettings.json`。

#### 恢复 (Recovery)
1.  **恢复文件**：将文件归档解压到映射的卷目录。
2.  **启动数据库**：启动数据库容器。
3.  **导入数据**：使用 `psql` 导入 SQL 转储文件。
4.  **启动应用**：启动全栈服务。

有关完整指南，请参阅 [恢复文档](Further-TBD/RECOVERY.MD)。
