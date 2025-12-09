# GZCTF 题目分类管理器

此目录包含用于 GZCTF 开发和管理的实用脚本。

## manage_challenges.ps1

这是主要的实用脚本。它允许您管理 GZCTF 平台中的题目分类。它通过修改必要的 C# (`Enums.cs`)、TypeScript (`Shared.tsx`) 和 JSON (`challenge.json`) 文件，自动化添加新分类的过程。

### 功能特性

- **列出分类**：查看当前配置的所有分类。
- **添加分类**：通过交互式向导添加新分类。
- **编辑翻译**：修改特定语言的翻译（国际化 i18n）。
- **颜色分析**：分析分类中的颜色使用情况并检测未定义的颜色。
- **自定义颜色**：定义并注册主题的自定义十六进制颜色。
- **备份与恢复**：在修改前自动备份文件，并允许轻松回滚。
- **持久化**：将分类定义保存到 `name/*.json` 以便重新应用。

### 使用方法

在此目录中打开 PowerShell 终端。

#### 交互模式（推荐）
不带参数运行脚本以进入交互式 Shell。
```powershell
.\manage_challenges.ps1
```
您将看到 `GZCTF` 提示符。您可以直接输入命令：

```text
GZCTF> ls all
GZCTF> wrt opensource -n
GZCTF> edit opensource
GZCTF> colors
GZCTF> help
GZCTF> exit
```

#### 脚本模式（旧版）
您仍然可以直接从 PowerShell 运行单个命令。

**1. 列出分类**
```powershell
.\manage_challenges.ps1 ls all
```

**2. 添加新分类**
启动交互式向导以添加新分类（例如 "opensource"）。
```powershell
.\manage_challenges.ps1 wrt opensource -n
```
系统将提示您输入：
- **Label**：中文显示名称（例如 "开源情报"）。
- **LabelEn**：英文显示名称（例如 "Open Source Intelligence"）。
- **Icon**：MDI 图标名称（例如 "mdiSearchWeb"）。
- **Color**：Mantine 颜色名称（例如 "orange"）。
- **Enum Name**：内部 C# 枚举名称（例如 "OSINT"）。

**国际化 (i18n)：**
脚本会自动检测 `src/locales` 中的所有语言文件夹。
- 创建分类时，如果您只提供中文/英文标签，所有其他语言（例如 `ja-JP`、`ru-RU`）将默认为英文标签。
- 您稍后可以使用 `edit` 命令更新这些内容。

**3. 编辑翻译**
在创建后修改特定语言的翻译：
```powershell
.\manage_challenges.ps1 edit opensource
```
这将启动一个交互式向导，您可以选择一种语言（例如 `ja-JP`）并输入新的翻译。

#### 可用颜色
系统使用 Mantine 主题引擎。您可以使用标准颜色或交互式定义新颜色。

**标准 Mantine 颜色：**
- `red`, `pink`, `grape`, `violet`, `indigo`, `blue`, `cyan`, `teal`, `green`, `lime`, `yellow`, `orange`, `gray`, `dark`

**GZCTF 自定义颜色：**
- `brand` (蓝绿色/绿色变体)
- `alert` (红色变体)
- `light` (白色/浅灰色变体)

**新自定义颜色：**
如果您输入的颜色名称不在上述列表中（例如 `cyberpunk`），脚本将询问您是否要创建它。如果您选择是，您可以提供十六进制代码（例如 `#FF00FF`），脚本将使用 Mantine 的 `generateColors` 工具自动将其注册在 `ThemeOverride.ts` 中。

**4. 恢复备份**
如果出现问题，您可以恢复原始文件。
```powershell
.\manage_challenges.ps1 wrt cancel -a
```

**5. 应用所有分类**
将 `name/` 目录中找到的所有分类重新应用到源代码。如果您手动编辑了 JSON 文件，这很有用。
```powershell
.\manage_challenges.ps1 wrt cover -a
```

**6. 分析颜色**
查看所有可用颜色（标准 + 自定义）的报告，并查看哪些分类正在使用它们。这有助于防止颜色冲突并识别未定义的颜色。
```powershell
.\manage_challenges.ps1 colors
```

### 目录结构

- `manage_challenges.ps1`：主脚本。
- `list_challenges.ps1`：旧版只读列表脚本。
- `backup/`：包含修改文件的原始副本。
- `name/`：包含每个分类的 JSON 定义。
