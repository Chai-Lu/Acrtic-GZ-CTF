# GZ::CTF 数据备份与恢复指南

本文档详细说明了在服务器部署环境下（Docker Compose），如何对 GZ::CTF 平台进行完整的数据存档（备份）与恢复。

## 1. 备份 (Backup)

完整备份需要保存两部分核心数据：**数据库**（PostgreSQL）和**文件存储**（附件/图片）。

### 1.1 数据库备份
数据库存储了用户信息、比赛配置、提交记录、Flag 等核心结构化数据。

假设：
- 数据库容器名为: `gzctf-db`
- 数据库用户名为: `postgres`
- 数据库名为: `gzctf`

在宿主机执行以下命令：

```bash
# 导出数据库为 SQL 文件
docker exec -t gzctf-db pg_dump -U postgres gzctf > gzctf_backup_$(date +%Y%m%d).sql
```

### 1.2 文件存储备份
平台上传的题目附件、Writeup、用户头像等文件默认存储在容器的 `/app/files` 目录。

#### 情况 A：使用了 Docker 卷挂载（推荐）
查看 `docker-compose.yml` 中 `volumes` 部分，找到挂载到 `/app/files` 的宿主机目录（例如 `./files`）。

```bash
# 打包挂载目录
tar -czvf files_backup_$(date +%Y%m%d).tar.gz ./files
```

#### 情况 B：数据在容器内（未挂载卷）
如果未配置挂载，需要从应用容器（假设名为 `gzctf-app`）中复制出来：

```bash
# 1. 从容器复制到宿主机
docker cp gzctf-app:/app/files ./files_temp

# 2. 打包
tar -czvf files_backup_$(date +%Y%m%d).tar.gz ./files_temp

# 3. 清理临时目录
rm -rf ./files_temp
```

### 1.3 配置文件备份
建议同时备份以下配置文件，以便在新环境快速还原部署配置：
- `docker-compose.yml`
- `appsettings.json` (如果有自定义修改)
- `.env` (如果有环境变量配置)

---

## 2. 恢复 (Recovery)

在新的服务器或重新部署时，按照以下步骤恢复数据。

### 2.1 准备环境
确保 `docker-compose.yml` 和相关配置文件已就位。

### 2.2 恢复文件存储
将备份的附件文件解压到 `docker-compose.yml` 中指定的挂载目录位置。

```bash
# 解压文件包
tar -xzvf files_backup_2025xxxx.tar.gz

# 确保目录权限正确（容器内通常使用 root 或特定用户，视具体配置而定）
# 如果遇到权限问题，可以尝试放宽权限
chmod -R 755 ./files
```

### 2.3 启动数据库容器
先只启动数据库服务，以便导入数据。

```bash
docker compose up -d db
```

等待数据库完全启动（可以通过 `docker compose logs -f db` 查看日志，直到看到 "database system is ready to accept connections"）。

### 2.4 恢复数据库数据
将备份的 SQL 文件导入到运行中的数据库容器。

```bash
# 导入数据
cat gzctf_backup_2025xxxx.sql | docker exec -i gzctf-db psql -U postgres gzctf
```

### 2.5 启动应用
数据恢复完成后，启动剩余的应用服务。

```bash
docker compose up -d
```

## 3. 常见问题

- **数据库连接失败**：检查 `appsettings.json` 或环境变量中的 `ConnectionStrings:Database` 是否与 `docker-compose.yml` 中的数据库密码和端口一致。
- **附件无法下载/图片不显示**：通常是文件权限问题或挂载路径不一致。检查宿主机 `./files` 目录的内容是否完整，以及容器是否成功挂载了该目录。
