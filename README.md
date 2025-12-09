# Acrtic-GZ-CTF

[Ori-English](./README.en.md) | [源-简体中文](./README.zh.md) | [源-日本語](./README.ja.md)
[English](./README.new.en.md)

这是一个定制化的 GZ::CTF 平台环境。

##  快速开始 (Quick Start)

提供了两个启动脚本，适用于不同的场景：

### 1. `start_env.bat` (推荐用于演示/预览)
*   **核心逻辑**：先编译前端，再启动后端。
*   **特点**：模拟生产环境（后端托管静态前端文件），启动后无需额外的前端服务。不支持前端热更新。
*   **用法**：`.\start_env.bat`

### 2. `start_dev.bat` (推荐用于开发)
*   **核心逻辑**：环境检查 + 证书配置 + 依赖安装 + 启动后端。
*   **特点**：自动配置 HTTPS 开发证书，安装前端依赖。适合开发者首次配置环境或进行代码开发（配合 IDE 使用）。
*   **用法**：`.\start_dev.bat`

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

### 本地测试 (Local Testing)

你可以在本机直接测试生成的 Release 包，这不会影响现有的 Git 仓库代码。

**使用预设配置 (Using Saves):**
为了方便本地快速测试，`Further-TBD/saves/` 目录中包含了一套预设的配置文件（`appsettings.json` 和 `docker-compose.yml`），其中已配置好本地测试专用的密码。
*   该目录被 Git 忽略（除了 `.gitkeep`），你可以安全地将自己的测试配置保存在这里。
*   **使用方法**：Release 生成后，将 `saves` 目录下的所有文件复制到 `release` 目录中覆盖即可。

**测试步骤:**

1.  **停止开发环境**：如果正在运行 `start_env.bat` 或其他占用 8080 端口的服务，请先停止它们。
2.  **应用配置**：将 `Further-TBD/saves/` 中的配置文件复制到 `Further-TBD/release/`。
3.  **启动 Release**：
    ```powershell
    cd Further-TBD/release
    # 如果是 local 模式生成，且本地已有镜像，可跳过 load 步骤
    docker-compose up -d
    ```
4.  **访问**：浏览器访问 `http://localhost:8080`。
5.  **清理**：测试完成后，停止并移除容器：
    ```powershell
    docker-compose down
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
