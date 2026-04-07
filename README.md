# tpl-app


通用应用模板，包含四个子模块，用于快速初始化新项目。

<!-- synced with init.sh + web-frontend Next standalone -->

## 仓库结构

```
tpl-app/
├── init.sh                  # 初始化脚本
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
- 用户端前端（Next.js）内置 BFF（`/api/auth/`），可单独对接 Casdoor，无需 `tpl-web-backend`
- 若前端不带 BFF（纯 CSR），则由对应后端负责 Casdoor 对接

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
