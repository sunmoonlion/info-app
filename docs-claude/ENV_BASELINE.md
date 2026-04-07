# 环境基线（ENV BASELINE）

> 记录本地开发环境的搭建方式和连接参数。
> 新成员照此操作应能在 30 分钟内把服务跑起来。

---

## 前置条件

- Node.js {{版本}}
- Python {{版本}}（如有后端）
- Docker（可选，用于本地基础设施）
- pnpm / npm / yarn

---

## 基础设施

> 按项目实际使用的服务填写，删除不需要的行。

| 服务 | 地址 | 说明 |
|------|------|------|
| {{数据库，e.g. PostgreSQL / MySQL}} | `host:port` | 数据库 |
| {{缓存，e.g. Redis}} | `host:port` | Session / 缓存（如有） |
| {{认证，e.g. Casdoor / Auth0}} | `https://...` | OIDC 认证中心（如有） |

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
NEXT_PUBLIC_BFF_PROVIDER=frontend   # frontend | backend
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
cp .env.example .env            # 填写实际值
{{uv sync / pip install -r requirements.txt / npm install}}
{{alembic upgrade head}}        # 数据库迁移（如使用 alembic）
{{uvicorn app.main:app --reload --port 8000 / node dist/main.js}}
```

关键环境变量（`.env`）：

```env
DATABASE_URL={{postgresql+asyncpg / mysql+aiomysql / ...}}://user:pass@host:port/dbname
REDIS_URL=redis://:password@host:port/0
CASDOOR_ENDPOINT=https://...
CASDOOR_CLIENT_ID=...
CASDOOR_CLIENT_SECRET=...
CASDOOR_REDIRECT_URI=http://localhost:8000/auth/callback
```

---

## 验证启动成功

```bash
# 后端健康检查
curl http://localhost:8000/health

# 前端
open http://localhost:3000
```

---

## 常见问题

**Q：数据库连接失败**
A：检查 `DATABASE_URL` 中的 host/port/密码；确认数据库服务已启动。

**Q：Redis 连接失败**
A：检查 `REDIS_URL`；确认 Redis 服务已启动。

**Q：{{其他常见问题}}**
A：{{解决方案}}
