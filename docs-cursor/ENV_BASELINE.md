# 环境基线（ENV BASELINE）

> 记录本地开发环境的搭建方式和连接参数。
> 新成员照此操作应能在 30 分钟内把服务跑起来。

---

## 前置条件

| 工具 | 版本要求 | 说明 |
|------|---------|------|
| Node.js | {{版本}} | 建议 nvm 管理 |
| Python | {{版本}} | 如有后端 |
| pnpm / npm | 最新 | 前端包管理 |
| Docker | 可选 | 本地基础设施 |

---

## 基础设施

| 服务 | 地址 | 认证 | 说明 |
|------|------|------|------|
| PostgreSQL | `host:port` | user / pass | 数据库 |
| Redis | `host:port` | 密码 | Session / 缓存 |
| Casdoor | `https://...` | client_id / secret | OIDC 认证中心 |

---

## 前端启动

```bash
cd {{frontend-repo}}
pnpm install
cp .env.example .env.local   # 填写实际值
pnpm dev
```

关键环境变量（`.env.local`）：

```env
NEXT_PUBLIC_API_URL=http://localhost:8000
CASDOOR_ENDPOINT=https://...
CASDOOR_CLIENT_ID=...
CASDOOR_CLIENT_SECRET=...
CASDOOR_REDIRECT_URI=http://localhost:3000/api/auth/callback
REDIS_URL=redis://:password@host:port/0
```

---

## 后端启动

```bash
cd {{backend-repo}}/app
cp .env.example .env          # 填写实际值
uv sync                       # 安装依赖（或 pip install -r requirements.txt）
alembic upgrade head          # 数据库迁移
uvicorn app.main:app --reload --port 8000
```

关键环境变量（`.env`）：

```env
DATABASE_URL=postgresql+asyncpg://user:pass@host:port/dbname
REDIS_URL=redis://:password@host:port/0
CASDOOR_ENDPOINT=https://...
CASDOOR_CLIENT_ID=...
CASDOOR_CLIENT_SECRET=...
CASDOOR_REDIRECT_URI=http://localhost:8000/auth/callback
```

---

## 验证启动成功

```bash
curl http://localhost:8000/health   # 后端健康检查
# 浏览器访问 http://localhost:3000  # 前端
```

---

## 启动顺序

1. 数据库（PostgreSQL）
2. Redis
3. 后端 API
4. 前端

---

## 常见问题

| 问题 | 排查方向 |
|------|---------|
| 数据库连接失败 | 检查 `DATABASE_URL`；确认数据库服务已启动 |
| Redis 连接失败 | 检查 `REDIS_URL`；确认密码正确 |
| 端口占用 | `lsof -i :8000` 或 `netstat -ano | findstr 8000` |
| {{其他}} | {{排查方向}} |

详见 `RUNBOOK.md`。
