# Acrtic-GZ-CTF

[Ori-English](./README.en.md) | [源-简体中文](./README.zh.md) | [源-日本語](./README.ja.md)
[English](./README.new.en.md)

这是一个定制化的 GZ::CTF 平台环境。

##  快速开始 (Quick Start)

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

##  发布生成 (Release Generation)

如果你需要生成用于生产环境部署的独立包（包含 Docker 配置），可以使用发布生成脚本。

### 发布生成脚本 (Release Scripts)

位于 `Further-TBD/` 目录下，提供三种生成方式：

1.  **`generate_release_network.ps1` (推荐)**
    *   **适用场景**：网络环境良好，Docker 容器内可以访问 GitHub。
    *   **功能**：标准构建流程，自动在 Docker 构建过程中下载 `Satori` 依赖。
    *   **用法**：`.\generate_release_network.ps1`

2.  **`generate_release_local.ps1` (离线/网络受限)**
    *   **适用场景**：Docker 容器内网络受限，无法下载依赖。
    *   **功能**：使用本地预先下载的依赖文件。
    *   **前置要求**：需手动下载 `linux_musl_amd64.zip` (或 `arm64`) 并放置在 `Further-TBD/locallybuild/` 目录下。
    *   **用法**：`.\generate_release_local.ps1`

3.  **`app.ps1` (旧版)**
    *   **适用场景**：需要旧版目录结构 (`release/app`)。
    *   **功能**：生成旧版部署结构。
    *   **用法**：`.\app.ps1`

### 发布包结构 (Release Package Structure)

生成的 `release` 目录是一个完整的离线部署包，包含：
*   `images/gzctf.tar`: 包含完整应用和依赖的离线 Docker 镜像。
*   `docker-compose.yml`: 服务编排文件。
*   `appsettings.json`: 应用配置文件。
*   `version.md`: 版本信息。
*   `data/`: 预创建的数据挂载目录。

**通用用法 (General Usage)：**
```powershell
cd Further-TBD
.\generate_release_local.ps1 # 示例
# 按提示输入版本号，或直接回车使用默认值
```

**部署方法 (Deployment)：**

将生成的 `release` 目录发送给部署人员，在目标机器上执行：
```powershell
cd release
# 1. 导入离线镜像
docker load -i images/gzctf.tar
# 2. 启动服务
docker-compose up -d
```

---

##  备份与恢复 (Backup & Recovery)

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
