# tpl-app


通用应用模板，包含四个子模块，用于快速初始化新项目。

<!-- synced with init.sh + web-frontend Next standalone -->

## 仓库结构

```
tpl-app/
├── init.sh                  # 初始化脚本
├── .cursor/rules/           # Cursor 规则（.mdc，按 globs 生效）
├── CLAUDE.md                # Claude Code 项目上下文模板
├── docs-claude/             # Claude Code 文档体系模板
├── docs-cursor/             # Cursor 文档体系模板
├── tpl-admin-frontend/      # 管理后台前端（Vue 3 + Vite，CSR）
├── tpl-admin-backend/       # 管理后台后端（FastAPI + SQLAlchemy）
├── tpl-web-frontend/        # 用户端前端（Next.js 16，SSR）
└── tpl-web-backend/         # 用户端 BFF 后端（NestJS + TypeScript）
```

## 子模块说明

| 子模块 | 技术栈 | 说明 |
|--------|--------|------|
| tpl-admin-frontend | Vue 3 + Vite | 管理后台，CSR 模式 |
| tpl-admin-backend | FastAPI + Python 3.12 | 管理后台后端，DDD 架构，Casdoor BFF 认证 |
| tpl-web-frontend | Next.js 16 + shadcn/ui | 用户端前端，SSR 模式，Casdoor BFF 认证 |
| tpl-web-backend | NestJS + TypeScript | 用户端 BFF 后端，Casdoor OIDC 对接 |

## 组合方式

四个子模块可按需两两组合：

```
管理端：tpl-admin-frontend  +  tpl-admin-backend
用户端：tpl-web-frontend    +  tpl-web-backend
```

BFF 认证说明：
- 当前建议采用「后端 BFF 统一对接 Casdoor」模式：
  - `tpl-web-frontend` 跳转到 `tpl-web-backend /auth/login`
  - `tpl-admin-frontend` 跳转到 `tpl-admin-backend /auth/login`
  - 前端不直接对接 Casdoor token 交换流程

## 当前认证与权限架构（已落地）

本仓库当前以 **Casdoor 为唯一身份源**，目标是：
- 用户注册/创建在 Casdoor 完成
- 登录与会话由后端 BFF 处理
- 接口级权限由 Casdoor token 声明驱动
- 本地用户表仅做影子同步（映射/业务扩展），不是认证权威

### 1) `tpl-web-backend`（NestJS）

已完成：
- `/auth/login|callback|logout|me` Casdoor OIDC 链路
- `JwtGuard` 从 `session_id` 读取 Redis 会话
- `RolePermissionGuard` 改为读取 `req.user.casdoorPermissions`
- `AuthService` 从 `id_token` 解析 claims，并组装 `username` + `casdoorPermissions`
- 登录回调后自动 upsert 本地 `users`（影子同步）
- 禁用手工创建用户：`POST /user` 返回 `410 Gone`
- 去除本地密码认证链路（不再用于本地登录）

说明：
- 权限字符串需要与后端装饰器拼接一致（如 `user:read`）
- 若 token 中给到 `*`，可作为全量放行（仅建议测试/过渡）

### 2) `tpl-admin-backend`（FastAPI）

已完成：
- 仅保留 `/auth/login|callback|logout|me`
- 登录回调后自动解析 `id_token` 并 upsert 本地 `users`（影子同步）
- 字段同步：`username`、`casdoor_sub`、`email`、`full_name`
- 仍由 Casdoor 负责认证与权限权威

### 3) 影子同步原则

影子表用途：
- 业务关联（外键/展示）
- 审计快照
- 本地扩展字段

非用途：
- 不做登录密码校验
- 不作为权限权威（权限以 Casdoor 为准）

### 4) Casdoor 配置要求

必须保证：
- `CASDOOR_REDIRECT_URI` 与后端回调地址完全一致
- token 中可解析出后端需要的权限声明
- 权限命名与后端一致（`resource:action`）

当前后端会从以下 claims 字段提取权限：
- `permissions`
- `permission`
- `roles`
- `role`

### 5) 子模块拉取注意事项

首次建议：

```bash
git clone --recurse-submodules https://gitee.com/sunmoonlion/tpl-app.git
```

已有仓库更新：

```bash
git pull
git submodule update --init --recursive
```

若出现 `not our ref`，通常是父仓库记录的子模块提交在子仓远程不存在，需要修复子模块指针或恢复对应提交。

## 使用方法

### 1. 克隆模板（含子模块）

```bash
git clone --recurse-submodules https://gitee.com/sunmoonlion/tpl-app.git <新项目名>-app
cd <新项目名>-app
```

### 2. 执行初始化脚本

```bash
bash init.sh <项目名> <Gitee用户名>
```

示例：

```bash
bash init.sh investment sunmoonlion
```

脚本会自动完成：
- 将四个子模块内所有文件中的 `tpl` / `Tpl` / `TPL` 替换为项目名
- 重命名四个子模块目录，并修正各子模块 `.git` 指针
- 更新 `.gitmodules` 中的远程 URL

### 3. 重命名父目录

```bash
cd ..
mv <新项目名>-app <正式目录名>
```

### 4. 在 Gitee 上新建仓库

需要新建五个仓库（均为空仓库，不加 README）：

- `<项目名>-app`
- `<项目名>-admin-frontend`
- `<项目名>-admin-backend`
- `<项目名>-web-frontend`
- `<项目名>-web-backend`

### 5. 推送

```bash
# 推送四个子模块
cd <项目名>-admin-frontend && git push -u origin master && cd ..
cd <项目名>-admin-backend  && git push -u origin master && cd ..
cd <项目名>-web-frontend   && git push -u origin master && cd ..
cd <项目名>-web-backend    && git push -u origin master && cd ..

# 推送父仓库
git remote set-url origin https://gitee.com/<Gitee用户名>/<项目名>-app.git
git push -u origin master
```
