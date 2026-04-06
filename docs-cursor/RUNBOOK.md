# 操作手册（RUNBOOK）

> 可执行的操作步骤集合，用于启动、排查、恢复。
> 照着做就能跑，不依赖口头传授。

---

## 一、本地启动（开发环境）

### 1.1 启动顺序

```bash
# 1. 数据库
docker start postgres   # 或系统服务

# 2. Redis
docker start redis      # 或系统服务

# 3. 后端
cd {{backend-repo}}/app
uvicorn app.main:app --reload --port 8000

# 4. 前端
cd {{frontend-repo}}
pnpm dev
```

### 1.2 验证

```bash
curl http://localhost:8000/health
# 浏览器访问 http://localhost:3000
```

---

## 二、数据库操作

### 运行迁移

```bash
cd {{backend-repo}}/app
alembic upgrade head
```

### 回滚一步

```bash
alembic downgrade -1
```

### 查看当前版本

```bash
alembic current
```

---

## 三、常见问题排查

### 端口已占用

```bash
# Linux / Mac
lsof -i :8000

# Windows
netstat -ano | findstr 8000
taskkill /PID <pid> /F
```

### 数据库连接失败

1. 确认数据库服务已启动
2. 检查 `.env` 中 `DATABASE_URL` 的 host / port / user / password
3. 尝试 `psql -h host -p port -U user -d dbname` 手动连接

### Redis 连接失败

1. 确认 Redis 服务已启动
2. 检查 `REDIS_URL` 中的密码
3. 尝试 `redis-cli -h host -p port -a password ping`

### 前端构建失败

1. 删除 `node_modules` 后重新 `pnpm install`
2. 检查 Node.js 版本是否符合要求
3. 查看具体报错信息

---

## 四、Casdoor 配置

### 确认 redirect_uri 配置正确

在 Casdoor 管理界面 → 应用 → 回调地址，确保包含：
- 本地：`http://localhost:3000/api/auth/callback`（或后端 callback 地址）
- 生产：`https://{{your-domain}}/api/auth/callback`

### 测试登录流程

```bash
# 访问 BFF 登录入口，观察是否正确跳转 Casdoor
curl -v http://localhost:8000/auth/login
# 或前端 BFF
curl -v http://localhost:3000/api/auth/login
```

---

## 五、{{其他操作场景}}

{{按需补充}}
