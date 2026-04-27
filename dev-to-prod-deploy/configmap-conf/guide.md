# configmap-conf — 非敏感配置的 Dev → ConfigMap 指南

## ConfigMap 收录什么

ConfigMap 存放 Pod 运行所需的**非敏感**环境变量。判断标准：

- 泄露后不会直接导致系统被攻击（无密码、无 token、无私钥）
- 需要在开发和生产之间有不同值
- 应用通过环境变量读取（`process.env.XXX` 或 pydantic-settings）

## 从开发侧哪里取字段

### 主要来源：`app/.env`

扫描 `.env` 文件，把**不含密码/密钥**的字段列出来，逐项判断是否进 ConfigMap。

常见模式（直接进 ConfigMap）：
```
LOG_LEVEL=
NODE_ENV=
PORT=
PREFIX=
CORS=
REDIS_HOST=
REDIS_PORT=
SMTP_HOST=
SMTP_PORT=
SMTP_TLS=
```

### 辅助来源：`app/core/config.py`（或等价的配置类）

pydantic-settings 的字段定义是**权威字段清单**：字段名以 config.py 为准，`.env` 里的 key 必须与之对齐。

重点检查：
- 字段名与 `.env` 里的 key 是否一致（历史上出现过 `DATABASE_URL` vs `SQLALCHEMY_DATABASE_URI`）
- 有 `alias` 或 `env` 参数的字段，用别名而非 Python 属性名

## 填写 generate-*-config.conf 的注意事项

### 注意一：服务地址必须改为 k8s 内部 Service DNS

`.env` 里的本地地址不能照搬：

| `.env`（本地开发） | `generate-*-config.conf`（k8s 生产） |
|------------------|--------------------------------------|
| `REDIS_HOST=localhost` | `REDIS_HOST=redis-sunmoonai.data-platform-dev.svc.cluster.local` |
| `DB_HOST=www.sunmoonai.com` | `DB_HOST=postgresql-sunmoonai.data-platform-dev.svc.cluster.local` |
| `DB_PORT=5433`（NodePort） | `DB_PORT=5432`（内部端口） |
| `NEO4J_SERVER=101.126.151.0` | `NEO4J_SERVER=neo4j-sunmoonai.data-platform-dev.svc.cluster.local` |

常见中间件的 k8s 内部 Service 名，查询方式：
```bash
kubectl get svc -n data-platform-dev
```

### 注意二：运行模式开关必须填生产值，不继承 `.env` 的开发值

| `.env`（开发） | `generate-*-config.conf`（k8s） |
|---------------|--------------------------------|
| `NODE_ENV=development` | `NODE_ENV=production` |
| `LOG_LEVEL=debug` | `LOG_LEVEL=warn` |
| `NODE_TLS_REJECT_UNAUTHORIZED=0` | 此行删除（或 `=1`） |
| `CASDOOR_VERIFY_SSL=false` | `CASDOOR_VERIFY_SSL=true` |

### 注意三：URL 类字段（CORS、redirect_uri）值完全不同

| `.env`（开发） | `generate-*-config.conf`（k8s） |
|---------------|--------------------------------|
| `CORS_ORIGINS=http://localhost:3000` | `CORS_ORIGINS=https://www.sunmoonai.com` |
| `CASDOOR_REDIRECT_URI=http://43.159.148.235:8000/...` | `CASDOOR_REDIRECT_URI=https://www.sunmoonai.com/...` |

建议在 `generate-*-config.conf` 里先定义 `APP_BASE_URL`，其他 URL 字段从它派生。

### 注意四：连接字符串模板（非密码部分）

如果 ConfigMap 需要存连接字符串模板（密码用 `PASSWORD` 占位，真实密码在 Secret 里），  
模板里的 host/port/user/db 必须是 k8s 内部值，不是本地值。

## 检查清单

填写完 `generate-*-config.conf` 后逐项确认：

- [ ] 所有服务地址（host/port）已改为 k8s 内部 Service DNS
- [ ] `NODE_ENV`、`LOG_LEVEL` 已改为生产值
- [ ] 所有 URL 类字段（CORS、redirect）已改为生产域名
- [ ] 无任何密码、密钥、token 出现在此文件（这些进 secret-conf）
- [ ] 字段名与私有仓库 `app/core/config.py` 的字段名一致
- [ ] ConfigMap YAML 模板中每个 key 与 `.conf` 里的变量名一一对应，无遗漏
- [ ] YAML 模板里无硬编码值，只有 `${VAR}` 占位符
