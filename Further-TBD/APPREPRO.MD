# APPREPRO.MD - GZ::CTF 前端重构与迁移全景指南 (Vue 3 Edition)

## 1. 项目概述与重构目标

本指南旨在指导开发者将 GZ::CTF 前端从 React 19 迁移至 Vue 3 (Composition API)。目标是**完美复刻**原有功能，保持后端接口不变，仅在前端进行技术栈替换。

### 1.1 技术栈对比与迁移策略

| 维度 | 原有方案 (React) | 目标方案 (Vue 3) | 迁移策略说明 |
| :--- | :--- | :--- | :--- |
| **框架** | React 19 | **Vue 3.4+ (Script Setup)** | 使用 Composition API (`<script setup>`) 对应 React Hooks。 |
| **构建工具** | Vite | **Vite** | 保持不变，配置需调整为 Vue 插件。 |
| **UI 组件库** | Mantine UI | **Naive UI** | Naive UI 风格简洁，组件丰富，适合后台与工具类应用。 |
| **状态管理** | React Context / SWR | **Pinia** | 使用 Pinia Store 管理全局状态 (User, Config)。 |
| **数据请求** | SWR | **TanStack Query (Vue Query)** | SWR 与 Vue Query 理念一致，迁移成本低。 |
| **路由** | React Router | **Vue Router 4** | 使用 `unplugin-vue-router` 实现文件系统路由（可选）或手动配置。 |
| **API 客户端** | Axios + Swagger Codegen | **Axios + Swagger TS API** | 继续使用 `swagger-typescript-api` 生成强类型客户端。 |
| **实时通信** | SignalR (@microsoft/signalr) | **SignalR + Vue Composable** | 封装 `useSignalR` composable 管理连接。 |

---

## 2. Vue 3 接口适配与调用规范 (Interface Adaptation)

在 Vue 3 中对接原有 ASP.NET Core 接口时，需遵循以下规范以确保平滑过渡。

### 2.1 API 客户端封装 (`src/api/index.ts`)

后端 API 定义在 `Api.ts` (由 Swagger 生成)。我们需要一个单例实例来管理拦截器。

```typescript
// src/api/index.ts
import { Api } from './Api';
import axios, { type AxiosInstance } from 'axios';
import { createDiscreteApi } from 'naive-ui';

const { message } = createDiscreteApi(['message']);

const axiosInstance: AxiosInstance = axios.create({
  baseURL: '/api', // Vite 代理转发到后端
  withCredentials: true, // 允许携带 Cookie
});

// 响应拦截器
axiosInstance.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response) {
      const { status, data } = error.response;
      if (status === 401) {
        // 未登录，跳转登录页或清理状态
        // router.push('/account/login');
      } else {
        // 显示后端返回的错误信息
        const msg = data.title || data.message || 'Request Failed';
        message.error(msg);
      }
    }
    return Promise.reject(error);
  }
);

export const api = new Api({
  instance: axiosInstance,
});
```

### 2.2 数据获取模式 (Data Fetching Pattern)

使用 `@tanstack/vue-query` 替代 SWR。

**React (SWR):**
```tsx
const { data } = useSWR('/api/game', fetcher);
```

**Vue 3 (Vue Query):**
```typescript
import { useQuery } from '@tanstack/vue-query';
import { api } from '@/api';

const { data, isLoading } = useQuery({
  queryKey: ['game', id],
  queryFn: () => api.game.gameGame(id).then(r => r.data)
});
```

### 2.3 实时通信模式 (SignalR Pattern)

封装 `useSignalR` composable。

```typescript
// src/composables/useSignalR.ts
import { HubConnectionBuilder, HubConnection } from '@microsoft/signalr';
import { ref, onUnmounted } from 'vue';

export function useSignalR(hubUrl: string) {
  const connection = ref<HubConnection | null>(null);

  const start = async () => {
    connection.value = new HubConnectionBuilder()
      .withUrl(hubUrl)
      .withAutomaticReconnect()
      .build();
    
    await connection.value.start();
  };

  const on = (methodName: string, callback: (...args: any[]) => void) => {
    connection.value?.on(methodName, callback);
  };

  onUnmounted(() => {
    connection.value?.stop();
  });

  return { connection, start, on };
}
```

---

## 3. 全局接口映射矩阵 (Master Interface Matrix)

本表涵盖了前端所有页面及其对应的后端接口。**开发时请直接查阅此表。**

### 3.1 账户与认证模块 (Account Module)

| 页面/组件 | 用户操作 | 后端接口 (Api.ts) | Vue 实现建议 |
| :--- | :--- | :--- | :--- |
| **Login.tsx** | 提交登录表单 | `api.account.accountLogIn` | `useMutation`。成功后调用 `userStore.fetchProfile()`。 |
| **Register.tsx** | 获取验证码配置 | `api.info.infoGetClientCaptchaInfo` | `useQuery`。根据配置决定是否显示验证码。 |
| | 获取 PoW 挑战 | `api.info.infoPowChallenge` | 若配置为 HashPow，需前端计算 PoW。 |
| | 提交注册 | `api.account.accountRegister` | `useMutation`。 |
| **Profile.tsx** | 加载个人信息 | `api.account.accountProfile` | `useQuery`。 |
| | 修改基本信息 | `api.account.accountUpdate` | `useMutation`。 |
| | 修改密码 | `api.account.accountChangePassword` | `useMutation`。 |
| | 上传头像 | `api.account.accountAvatar` | 使用 `NUpload` 组件，`customRequest` 调用 API。 |
| **Recovery.tsx** | 发送重置邮件 | `api.account.accountRecovery` | `useMutation`。 |
| **Reset.tsx** | 重置密码 | `api.account.accountPasswordReset` | `useMutation`。需携带 URL 中的 Token。 |
| **Verify.tsx** | 验证邮箱 | `api.account.accountVerify` | `onMounted` 自动调用。 |

### 3.2 公共与信息模块 (Public & Info)

| 页面/组件 | 用户操作 | 后端接口 (Api.ts) | Vue 实现建议 |
| :--- | :--- | :--- | :--- |
| **Global Layout** | 获取全局配置 | `api.info.infoGetClientConfig` | 在 `App.vue` 或 `ConfigStore` 中初始化调用。 |
| **Index.tsx (Home)** | 获取最新公告 | `api.info.infoGetLatestPosts` | `useQuery`。展示前 5-10 条。 |
| **posts/Index.tsx** | 获取所有公告 | `api.info.infoGetPosts` | `useQuery`。 |
| **posts/[id]** | 获取公告详情 | `api.info.infoGetPost` | `useQuery(['post', id])`。 |
| **Teams.tsx** | 获取我的队伍 | `api.team.teamGetTeamsInfo` | `useQuery`。 |
| | 创建队伍 | `api.team.teamCreateTeam` | `useMutation`。 |
| | 加入队伍 | `api.team.teamAccept` | `useMutation`。需输入邀请码。 |
| | 退出/解散队伍 | `api.team.teamDeleteTeam` | `useMutation`。 |

### 3.3 比赛核心模块 (Game Module)

| 页面/组件 | 用户操作 | 后端接口 (Api.ts) | Vue 实现建议 |
| :--- | :--- | :--- | :--- |
| **games/Index.tsx** | 获取比赛列表 | `api.game.gameGames` | `useQuery`。支持分页。 |
| **games/[id]/Index.tsx** | 获取比赛详情 | `api.game.gameGame` | `useQuery`。包含描述、时间、规则。 |
| | 报名比赛 | `api.game.gameJoinGame` | `useMutation`。需选择队伍。 |
| **games/[id]/Challenges.tsx** | 获取题目列表 | `api.game.gameChallengesWithTeamInfo` | **核心**。`useQuery`。返回题目及当前解题状态。 |
| **ChallengeModal.vue** | 获取题目详情 | `api.game.gameGetChallenge` | 点击题目时触发 `useQuery` (enabled: true)。 |
| | 创建容器 | `api.game.gameCreateContainer` | `useMutation`。 |
| | 销毁容器 | `api.game.gameDeleteContainer` | `useMutation`。 |
| | 提交 Flag | `api.game.gameSubmit` | `useMutation`。 |
| | 提交 Writeup | `api.game.gameSubmitWriteup` | `useMutation`。 |
| **games/[id]/Scoreboard.tsx** | 获取排行榜 | `api.game.gameScoreboard` | `useQuery`。定时刷新 (refetchInterval)。 |

### 3.4 监控模块 (Monitor Module) - 需 Monitor/Admin 权限

| 页面/组件 | 用户操作 | 后端接口 (Api.ts) | Vue 实现建议 |
| :--- | :--- | :--- | :--- |
| **monitor/Events.tsx** | 获取事件日志 | SignalR `ReceivedGameEvent` | 连接 `MonitorHub`，监听事件并追加到列表。 |
| **monitor/Submissions.tsx** | 获取提交记录 | SignalR `ReceivedSubmissions` | 连接 `MonitorHub`，监听提交并更新表格。 |
| **monitor/Traffic.tsx** | 获取流量日志 | (依赖后端日志流或特定API) | 通常通过 SignalR 或轮询日志接口。 |
| **monitor/CheatInfo.tsx** | 获取作弊分析 | `api.game.gameCheatInfo` (假设) | 需确认具体接口，通常在 GameController 或 AdminController。 |

### 3.5 管理后台模块 (Admin Module) - 需 Admin 权限

| 页面/组件 | 用户操作 | 后端接口 (Api.ts) | Vue 实现建议 |
| :--- | :--- | :--- | :--- |
| **Settings.tsx** | 获取系统配置 | `api.admin.adminGetConfigs` | `useQuery`。 |
| | 更新配置 | `api.admin.adminUpdateConfigs` | `useMutation`。 |
| **Users.tsx** | 获取用户列表 | `api.admin.adminUsers` | `useQuery`。支持分页、搜索。 |
| | 编辑用户 | `api.admin.adminUpdateUserInfo` | `useMutation`。 |
| **Teams.tsx** | 获取队伍列表 | `api.admin.adminTeams` | `useQuery`。 |
| **Instances.tsx** | 获取容器实例 | `api.admin.adminInstances` | `useQuery`。 |
| | 销毁实例 | `api.game.gameDeleteContainer` | 管理员也可调用此接口销毁任意容器。 |
| **games/Index.tsx** | 获取比赛列表(管) | `api.admin.adminGamesAdmin` | `useQuery`。 |
| | 创建比赛 | `api.admin.adminCreateGame` | `useMutation`。 |
| **games/[id]/Info.tsx** | 更新比赛信息 | `api.admin.adminUpdateGame` | `useMutation`。 |
| **games/[id]/Challenges.tsx** | 获取题目(管) | `api.edit.editGetChallengesAdmin` | `useQuery`。 |
| | 更新题目 | `api.edit.editUpdateChallenge` | `useMutation`。 |
| | 添加 Flag | `api.edit.editAddFlag` | `useMutation`。 |
| | 配置容器 | `api.edit.editUpdateContainer` | `useMutation`。 |
| **games/[id]/Notices.tsx** | 发布通知 | `api.admin.adminCreateNotice` | `useMutation`。 |

---

## 4. SignalR 事件监听指南

前端需连接对应的 Hub 并监听以下事件以实现实时更新。

### 4.1 UserHub (`/hub/user`)
*   **连接参数**: `?game={gameId}`
*   **监听事件**:
    *   `ReceivedGameNotice(notice: GameNotice)`: 收到新通知时，弹出提示或刷新通知列表。

### 4.2 MonitorHub (`/hub/monitor`)
*   **连接参数**: `?game={gameId}`
*   **权限**: Monitor 或 Admin
*   **监听事件**:
    *   `ReceivedGameEvent(gameEvent: GameEvent)`: 比赛事件（如一血、解题）。
    *   `ReceivedSubmissions(submission: Submission)`: 实时提交流。

### 4.3 AdminHub (`/hub/admin`)
*   **连接参数**: 无
*   **权限**: Admin
*   **监听事件**:
    *   `ReceivedLog(log: LogMessageModel)`: 系统后台日志流。

---

## 5. 实施步骤 (Implementation Steps)

### Step 1: 基础架构 (Infrastructure)
1.  初始化 Vue 3 + Vite + TS 项目。
2.  安装 `naive-ui`, `pinia`, `vue-router`, `@tanstack/vue-query`, `axios`, `@microsoft/signalr`.
3.  配置 `vite.config.ts` 代理 `/api` 和 `/hub` 到后端 (默认 `http://localhost:8080`)。
4.  生成 `src/api/Api.ts`。

### Step 2: 认证与用户 (Auth & User)
1.  实现 `useUserStore`，包含 `login`, `logout`, `profile` 状态。
2.  开发 `Login.vue`, `Register.vue`。
3.  开发 `Profile.vue`，对接头像上传和信息修改。

### Step 3: 队伍系统 (Team)
1.  开发 `Teams.vue`。
2.  实现“创建队伍”弹窗和“加入队伍”逻辑。

### Step 4: 比赛大厅 (Game Hall)
1.  开发 `GameList.vue` (`/games`)。
2.  开发 `GameDetail.vue` (`/games/:id`)。
3.  **重点**: 开发 `Challenges.vue`。
    *   使用 `NGrid` 展示题目卡片。
    *   封装 `ChallengeModal` 组件，处理题目详情、附件下载、容器启动、Flag 提交。
    *   **容器代理**: 若题目类型为 `DynamicContainer` 且 `portMappingType` 为 `PlatformProxy`，需使用 WebSocket 连接 `/api/Proxy/{id}` 进行终端交互 (使用 `xterm.js`)。

### Step 5: 管理后台 (Admin)
1.  搭建 Admin Layout (侧边栏导航)。
2.  实现 `GameManagement` (CRUD)。
3.  实现 `ChallengeEditor` (Markdown 编辑器, 动态表单)。

### Step 6: 实时与监控 (Real-time)
1.  在 `GameDetail` 挂载时连接 `UserHub`。
2.  在 `Scoreboard` 页面实现定时刷新或 SignalR 推送更新（如果后端支持）。
3.  开发 Monitor 页面，可视化展示提交流。

此文档提供了从架构到具体接口调用的完整映射，请按照 **Step 1 -> Step 6** 的顺序进行开发。
