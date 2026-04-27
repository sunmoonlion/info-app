# 部署框架问题清单

> 来源：2026-04-26 casdoor-app 首次部署暴露的非 Casdoor 问题  
> 适用范围：tpl-app 派生项目 + k8s/sunmoonai/app-platform 部署框架

---

## 问题一：`.env` 文件与 k8s ConfigMap/Secret 的断层

### 现状

`db-access-bootstrap` 在本地运行后，把数据库连接字符串、Redis 地址等写入应用目录下的 `app/.env`。本地开发直接读 `.env`，没问题；**但 k8s 部署时根本不用这个文件**——Pod 的环境变量来自 ConfigMap / Secret，两套配置完全独立维护。

具体症状（此次 casdoor 部署中出现）：

- `db-access-bootstrap/merge-and-generate-app-env.sh` 写入 `DATABASE_URL`
- `app/core/config.py`（pydantic-settings）读取 `SQLALCHEMY_DATABASE_URI`
- 本地 `.env` 和 k8s ConfigMap 都没人去对齐这个命名，部署后后端始终使用默认值连接数据库

### 根因

`.env`（本地开发）、k8s ConfigMap、k8s Secret 三者是**各自独立维护**的，没有单一事实来源（single source of truth）。任何一处字段改名或新增，另外两处都不会自动同步，靠"手写一致"迟早出错。

### 需要讨论的方向

如何在 `app-platform` 的部署框架里，把 `.env` 问题转化为 ConfigMap/Secret 问题：

- 谁是 single source of truth？（`.env.template`？`deploy.conf`？）
- `db-access-bootstrap` 产出物是 `.env`，还是直接生成 k8s Secret？还是两者都要？
- 本地开发和 k8s 部署如何共用同一份字段定义，不维护两套？

> 详细讨论见下一节（待补充）

---

## 问题二：db-access-bootstrap config 文件提交了环境敏感值

### 现状

`k8s/sunmoonai/app-platform/casdoor-app/casdoor/db-access-bootstrap/config/` 下有两个文件被提交到 git：

| 文件 | 问题 |
|------|------|
| `common.env` | `DBCTL_BIN` 写死了本机路径（Windows 路径），换机器即失效 |
| `postgresql.external.env` | `DB_HOST`（旧 IP）、`PG_ADMIN_PASSWORD`（明文密码）已过期且有泄露风险 |

### 影响

- 换机器 clone 后必须手动修改，否则脚本报错
- 密码明文提交到代码仓库，存在安全风险

### 修复方案

1. 将两个文件改为 `.example` 模板，提交占位值
2. 真实 config 文件加入 `.gitignore`
3. README 说明：首次使用需 `cp config/xxx.env.example config/xxx.env` 并填写真实值

```
config/
├── common.env.example          # 提交：含占位符
├── common.env                  # .gitignore：本机真实路径
├── postgresql.external.env.example  # 提交：含占位符
└── postgresql.external.env     # .gitignore：真实 IP / 密码
```

---

## 问题三：脚本执行权限未持久化到 git

### 现状

git 默认将文件以 `100644`（无执行位）存储。clone/pull 后所有 `.sh` 脚本和 `dbctl` 二进制都没有执行权限，必须手动 `chmod +x`。

### 修复方案

在每个涉及脚本的目录，执行一次：

```bash
# k8s repo
find /home/zym/k8s/sunmoonai -name "*.sh" -exec git update-index --chmod=+x {} \;

# investment-app / tpl-app（db-provisioner/bin/dbctl）
git update-index --chmod=+x <submodule>/db-provisioner/bin/dbctl
```

然后 commit 一次，之后 clone 自动带执行权限。

---

## 问题四：post-deploy-setup 只完成了一半

### 现状

`casdoor-app/casdoor/deploy-casdoor/post-deploy-setup.sh` 目前只做了一件事：

1. 向 Pod 内写入 `/conf/app.conf`（beego 配置）
2. Rollout restart

**没有自动化的**：

- 创建 Casdoor Organizations（`investment-web`、`investment-admin`）
- 创建 Casdoor Applications（`app-investment-web`、`app-investment-admin`）
- 配置 cert、grant_types、redirect_uri、enable_sign_up 等

这些目前全靠 psql 直接 INSERT，重新部署时必须手动重跑一遍 SQL。

### 修复方案

在 `post-deploy-setup.sh` 中追加：

1. 等待 Casdoor API 就绪（`/healthz` 或 `GET /api/get-app-list`）
2. 用 Casdoor Admin API（或直接 psql）幂等创建 Organizations + Applications
3. 整个脚本做到幂等（重复执行不报错、不重复创建）

---

## 优先级

| 优先级 | 问题 | 状态 |
|--------|------|------|
| 🔴 高 | 问题一：`.env` ↔ ConfigMap/Secret 断层（需专题讨论） | 待讨论 |
| 🔴 高 | 问题二：config 文件含敏感值被提交 | 待修复 |
| 🟡 中 | 问题三：脚本权限未持久化 | 待修复（5 分钟） |
| 🟡 中 | 问题四：post-deploy-setup 未完成 | 待实现 |

---

## 专题：从开发到 k8s 生产部署的完整转换框架

> 问题一是这个专题的起点，但实际范围更大。  
> 本节梳理所有需要在"本地开发"与"k8s 部署"之间做转换的配置维度，并以当前已有结构为基准提出修复方向。

---

### 基准：已有的 generate/deploy 二段式结构

以 `auth-app-backend` 为参考，app-platform 已有一套完整的转换架构：

```
resources/k8s-resource/
├── templates/              ← YAML 骨架，含 ${VAR} 占位符（提交 git）
│   ├── app/                ← Deployment + Service
│   ├── configMap/          ← ConfigMap
│   ├── secret/             ← Secret
│   ├── ingress/            ← IngressRoute
│   ├── pvc/                ← PersistentVolumeClaim
│   └── namespace/
└── custom-values/          ← 每个资源的值 + 生成脚本
    ├── app/generate-app/
    │   └── generate-app.conf         ← 镜像 tag、replicas、资源限制
    ├── configMap/<name>/generate-<name>/
    │   ├── generate-<name>.conf      ← ConfigMap 数据（非敏感，提交 git）
    │   ├── generate-<name>.sh        ← conf + template → *-generated.yaml
    │   └── *-generated.yaml          ← gitignored ✓
    └── secret/<name>/generate-<name>/
        ├── generate-<name>.conf      ← Secret 数据（⚠️ 含密码，应 gitignore！）
        ├── generate-<name>.sh
        └── *-generated.yaml          ← gitignored ✓

deploy-<component>/         ← 每个资源的部署脚本
├── app/deploy-app/         ← 调用 generate 脚本 → kubectl apply
├── configMap/.../deploy-*.sh
├── secret/.../deploy-*.sh
└── ...

resources/source/           ← 部分组件（如 llmops）：私有仓库源码在此
```

`generate-*.conf` 就是 k8s 侧的 `.env` 等价物。`*-generated.yaml` 已 gitignore，结构正确。

**当前存在的三处断层**，是本专题要解决的核心问题。

---

### 一、`.env` 的转换

本地开发所有配置集中在 `app/.env`（私有仓库）。进入 k8s 后，字段按性质流向不同的 `generate-*.conf`，最终生成不同类型的 k8s 资源。

#### 1.1 非敏感配置 → `generate-<name>-config.conf` → ConfigMap

字段名直接进 ConfigMap，值通常可以原样使用（但服务地址见 1.2）。

```
私有仓库 app/.env               k8s 侧 generate-*-config.conf
─────────────────────────────    ──────────────────────────────────
LOG_LEVEL=info              →    LOG_LEVEL=info
CASDOOR_ENDPOINT=https://...→    CASDOOR_ENDPOINT=https://...
REDIS_PORT=6379             →    REDIS_PORT=6379
NODE_ENV=development        →    NODE_ENV=production   ← 值必须覆盖（见 1.4）
```

**断层一**：字段命名不一致（如 `DATABASE_URL` vs `SQLALCHEMY_DATABASE_URI`）静默出错。  
→ 需要在私有仓库 `.env.template` 与 k8s 侧 `generate-*-config.conf` 之间约定统一字段名。

#### 1.2 服务地址端口 → `generate-<name>-config.conf`（值必须替换）

字段名可原样进 ConfigMap，但**值**在本地和 k8s 中完全不同，不能照搬。

| 字段 | 本地开发值（`.env`） | k8s 生产值（`generate-*-config.conf`） |
|------|-------------------|--------------------------------------|
| `DB_HOST` | `localhost` / `www.sunmoonai.com` | `postgresql-sunmoonai.data-platform-dev.svc.cluster.local` |
| `DB_PORT` | `5433`（NodePort） | `5432`（内部端口） |
| `REDIS_HOST` | `localhost` | `redis-sunmoonai.data-platform-dev.svc.cluster.local` |
| `CASDOOR_REDIRECT_URI` | `http://43.159.148.235:8000/...` | `https://www.sunmoonai.com/...` |
| `CORS_ORIGINS` | `http://localhost:3000` | `https://www.sunmoonai.com` |

**断层二**：`generate-*-config.conf` 里目前写的是旧服务器 IP（如 `POSTGRES_SERVER=101.126.151.0`），不是 k8s 内部 Service DNS。  
→ `generate-*-config.conf` 里的地址型字段应全部改为 k8s 集群内 Service DNS，与私有仓库 `.env` 的本地地址完全独立，不做自动转换。

#### 1.3 持久化存储路径 → `generate-<name>-pvc.conf` + Deployment volumeMount

本地用本机目录，k8s 用 PVC 挂载，路径由 Deployment YAML 的 `volumeMount` 决定，**不进 ConfigMap**。

| 字段示例（`.env`） | k8s 处理 | 落地位置 |
|------------------|---------|---------|
| `UPLOAD_PATH=/tmp/uploads` | PVC 挂载到 `/uploads` | `generate-*-pvc.conf` + Deployment `volumeMount` |
| `DATA_DIR=/home/zym/data` | PVC 挂载路径由 YAML 定义 | Deployment template |
| Casdoor `/conf` | PVC 覆盖镜像内置目录 | `generate-app.conf` + post-deploy 写入初始文件 |

#### 1.4 运行模式开关 → `generate-<name>-config.conf`（值必须是生产值）

这类字段控制运行行为，开发时宽松，生产时必须收紧。**私有仓库 `.env` 里是开发值，`generate-*-config.conf` 里必须写生产值，两者不做自动同步。**

| 字段 | 私有仓库 `.env`（开发） | `generate-*-config.conf`（k8s） |
|------|----------------------|--------------------------------|
| `NODE_ENV` | `development` | `production` |
| `LOG_LEVEL` | `debug` | `warn` |
| `NODE_TLS_REJECT_UNAUTHORIZED` | `0` | 此字段不出现（或 `1`） |
| `CASDOOR_VERIFY_SSL` | `false` | `true` |

#### 1.5 敏感凭据 → `generate-<name>-secret.conf` → Secret

密码、密钥等敏感字段进 Secret，`generate-*-secret.conf` 是它的填充文件。

**断层三（安全问题）**：当前 `generate-auth-app-backend-secret.conf` 含真实密码（`POSTGRES_PASSWORD=Po!s1359`、`SECRET_KEY=changeme`），**已提交到 git**。

现有 `.gitignore` 只忽略了 `*-generated.yaml`，未忽略 `generate-*-secret.conf`。

→ 修复方案：
```
# k8s-resource/.gitignore 补充
generate-*-secret.conf           ← 忽略含密码的 conf 文件

# 同时提交一个模板
generate-*-secret.conf.example   ← 含占位符，提交 git
```

首次部署时：`cp generate-*-secret.conf.example generate-*-secret.conf`，填入真实密码。

#### 1.6 本机专属字段 → 不进任何 `generate-*.conf`

| 字段示例 | 说明 |
|---------|------|
| `DBCTL_BIN=/home/zym/.../dbctl` | 本机工具路径，k8s 不需要 |
| `KUBECONFIG=~/.kube/...` | 本地 kubectl 配置 |

在私有仓库 `.env.template` 里标注 `# LOCAL_ONLY`，明确这些字段不向 k8s 侧同步。

---

### 二、其他从开发到 k8s 生产的转换维度

这些不来自 `.env`，但同样需要在 generate 阶段处理。

#### 2.1 镜像来源 → `generate-app.conf`（从 `build.conf` 读）

| 环境 | 来源 |
|------|------|
| 本地开发 | `docker build`（`mybuild/rebuild-and-run.sh`） |
| k8s 部署 | Harbor 镜像，`generate-app.conf` 里的 `image:` 字段 |

**断层**：`generate-app.conf` 里的镜像 tag 目前手写，与私有仓库 `mybuild/build.conf` 是两套，tag 不一致时部署旧镜像。

→ deploy 脚本在 generate 阶段从 `build.conf` 读 `IMAGE_REGISTRY`、`IMAGE_PROJECT`、`IMAGE_TAG`，注入 `generate-app.conf`，不手写。

#### 2.2 资源规格 → `generate-app.conf`（replicas / resources）

已有 `generate-app.conf`，目前是否有 replicas / resources.requests/limits 由各组件自定义。需统一字段名，按环境选值（dev=1 replica，prod=按需）。

#### 2.3 TLS 证书信任

| 环境 | 做法 |
|------|------|
| 本地开发 | 关闭 TLS 验证（`NODE_TLS_REJECT_UNAUTHORIZED=0`） |
| k8s 部署 | 信任集群 CA（挂载 CA 证书），或接入 cert-manager |

这是 1.4 中运行模式开关的延伸，属于生产就绪度问题，分阶段解决。

#### 2.4 Casdoor 初始化数据 → post-deploy-setup 自动化

见问题四，Organizations/Applications 创建应进入 `post-deploy-setup.sh` 幂等实现。

---

### 三、断层汇总与修复优先级

| # | 断层 | 位置 | 风险 | 修复难度 |
|---|------|------|------|---------|
| 1 | `generate-*-secret.conf` 含真实密码提交 git | k8s repo `k8s-resource/.gitignore` | 🔴 安全 | 低（加 gitignore + example） |
| 2 | `generate-*-config.conf` 地址用旧 IP 而非 k8s Service DNS | 各 `generate-*-config.conf` | 🔴 功能 | 中（逐个改值） |
| 3 | 私有仓库字段名与 k8s conf 字段名不对齐 | 私有仓库 `.env` vs k8s conf | 🟡 隐患 | 中（约定 + 校验） |
| 4 | 镜像 tag 手写，与 `build.conf` 脱节 | `generate-app.conf` | 🟡 功能 | 中（deploy 脚本读 build.conf） |
| 5 | 运行模式开关（NODE_ENV、LOG_LEVEL 等）在 k8s 侧未覆盖为生产值 | `generate-*-config.conf` | 🟡 安全 | 低（改字段值） |

---

### 四、设计原则小结

1. **`generate-*.conf` 是 k8s 侧的 `.env` 等价物**，两者独立维护，不做自动同步；字段名约定对齐，值各自独立
2. **`generate-*-secret.conf` 必须 gitignore**，提供 `.example` 模板；首次部署手动 cp + 填值
3. **地址类字段在 k8s 侧写 Service DNS**，不写 NodePort 外部地址
4. **运行模式开关在 k8s 侧写生产值**，不从 `.env` 继承开发值
5. **镜像 tag 从 `build.conf` 读**，deploy 脚本注入 `generate-app.conf`，不手写
