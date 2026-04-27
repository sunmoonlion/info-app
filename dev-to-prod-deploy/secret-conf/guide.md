# secret-conf — 敏感凭据的 Dev → Secret 指南

## Secret 收录什么

Secret 存放**泄露会直接导致安全风险**的凭据：

- 数据库密码（PostgreSQL、Redis、Neo4j 等）
- 应用签名密钥（`SECRET_KEY`、`TOTP_SECRET_KEY`、JWT secret）
- 第三方服务 token（SMTP 密码、Sentry DSN、对象存储密钥）
- Casdoor `CLIENT_SECRET`
- 第一个超级管理员账户密码

## 从开发侧哪里取字段

### 主要来源：`app/.env`

扫描 `.env`，把含以下关键词的字段列出来，一律进 Secret：

```
_PASSWORD   _SECRET    _KEY       _TOKEN
_DSN        _CREDENTIAL  PRIVATE_   _AUTH
```

常见字段：
```
POSTGRES_PASSWORD=
REDIS_PASSWORD=
NEO4J_PASSWORD=
SECRET_KEY=
TOTP_SECRET_KEY=
SMTP_PASSWORD=
SMTP_USER=           ← 视情况，有些 user 不敏感
SENTRY_DSN=          ← 含项目标识，建议进 Secret
FIRST_SUPERUSER_PASSWORD=
CASDOOR_CLIENT_SECRET=
```

### 辅助来源：`db-access-bootstrap` 产出的 `.env`

`db-access-bootstrap` 在本地运行后会写入 `app/.env`。  
其中 `DATABASE_URL`（含密码）、`REDIS_PASSWORD` 等字段来源于此，进 Secret。

## 安全规则（必须遵守）

### 规则一：`generate-*-secret.conf` 必须 gitignore

`generate-*-secret.conf` 含真实密码，**绝不能提交到 git**。

在 `resources/k8s-resource/` 的 `.gitignore` 里加入：
```
# 已存在（生成的 YAML 文件）
*-generated.yaml

# 必须补充（含密码的 Secret conf）
generate-*-secret.conf
```

### 规则二：提交 `.example` 模板，不提交真实值

每个 `generate-*-secret.conf` 对应提交一个 `generate-*-secret.conf.example`：

```bash
# generate-*-secret.conf.example（提交 git）
SECRET_KEY=changeme_replace_with_random_string
POSTGRES_PASSWORD=replace_with_real_password
REDIS_PASSWORD=replace_with_real_password
FIRST_SUPERUSER=admin@yourdomain.com
FIRST_SUPERUSER_PASSWORD=replace_with_real_password
SMTP_PASSWORD=
SENTRY_DSN=
```

首次部署：
```bash
cp generate-*-secret.conf.example generate-*-secret.conf
# 填入真实值
```

### 规则三：生产密码不复用开发密码

`app/.env` 里的开发密码（如 `POSTGRES_PASSWORD=dev123`）不应直接复制到 `generate-*-secret.conf`。  
生产密码应单独生成，建议：

```bash
# 生成随机 SECRET_KEY
python3 -c "import secrets; print(secrets.token_hex(32))"
# 或
openssl rand -hex 32
```

## 填写 generate-*-secret.conf 的注意事项

### 注意一：完整连接字符串（如 `DATABASE_URL`）的组装

有些 generate 脚本会自动从 ConfigMap 侧的 host/port/user/db 拼接完整 URL，  
Secret 侧只需提供密码部分（`POSTGRES_PASSWORD`）。  
有些脚本需要完整 `DATABASE_URL`，则在 Secret 里写完整字符串（含密码）。

查阅对应 `generate-*-secret.sh` 的逻辑确认。

### 注意二：base64 编码由 generate 脚本处理

不要手动 base64 编码后写入 conf。generate 脚本读取明文值，生成 Secret YAML 时自动编码。

### 注意三：Secret 命名与 Deployment 的 envFrom 对应

Secret 的 `name` 在 Deployment template 里通过 `envFrom.secretRef.name` 引用，  
需确认 `generate-*-secret.conf` 里定义的名称与 Deployment template 一致。

## 检查清单

- [ ] `generate-*-secret.conf` 已加入 `.gitignore`
- [ ] `generate-*-secret.conf.example` 已提交（含占位符，无真实密码）
- [ ] 生产密码与开发密码不同
- [ ] `SECRET_KEY` 已使用随机生成的值（非 `changeme`）
- [ ] 无任何 Secret 字段出现在 `generate-*-config.conf`（ConfigMap）里
- [ ] generate 脚本的 base64 逻辑已验证（不需手动编码）
- [ ] 完整连接字符串（`DB_URL`、`NEO4J_BOLT_URL`）由 generate 脚本自动拼接，不在 `.conf` 里手填含密码的完整字符串
- [ ] Secret YAML 模板里每个 key 与 `.conf` 变量名一一对应，模板内无硬编码值
