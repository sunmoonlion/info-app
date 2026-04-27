# app-conf — Deployment 配置的 Dev → generate-app.conf 指南

## generate-app.conf 负责什么

`generate-app.conf` 填充 Deployment + Service 的 YAML 模板，包含：

- 镜像地址和 tag
- 副本数（replicas）
- 资源限制（resources.requests/limits）
- 容器端口
- 健康检查探针参数
- 环境变量注入方式（envFrom ConfigMap/Secret）

这些内容**不来自 `.env`**，来自两个地方：**私有仓库的 `mybuild/build.conf`**（镜像相关）和部署决策（副本数、资源限制）。

## 从开发侧哪里取字段

### 来源一：私有仓库 `mybuild/build.conf`（镜像相关）

```bash
# mybuild/build.conf
WEB_BACKEND_IMAGE=investment-web-backend
WEB_BACKEND_TAG=1.0.0
WEB_BACKEND_IMAGE_REGISTRY=harbor.sunmoonai.com:30443
WEB_BACKEND_IMAGE_PROJECT=app-images
```

对应 `generate-app.conf` 里的镜像字段：
```bash
IMAGE_REGISTRY=harbor.sunmoonai.com:30443
IMAGE_PROJECT=app-images
IMAGE_NAME=investment-web-backend
IMAGE_TAG=1.0.0
# 最终 image: harbor.sunmoonai.com:30443/app-images/investment-web-backend:1.0.0
```

**关键约束**：`IMAGE_TAG` 必须与最近一次 `mybuild/push-image.sh --tag <tag>` 推送的 tag 一致，否则 k8s 拉取的是旧镜像。  
建议 deploy 脚本直接从 `build.conf` 读 tag，而不是手填。

### 来源二：`app/.env` 里的服务端口

应用监听的端口通常在 `.env` 或源码里定义：
```bash
PORT=8000    → containerPort: 8000
             → Service targetPort: 8000
```

Deployment template 里的 `containerPort` 和 Service 的 `targetPort` 必须与应用实际监听端口一致。

### 来源三：部署决策（不来自 `.env`，按环境手动设置）

这些值由基础设施决策决定，不从开发侧继承：

```bash
# generate-app.conf
REPLICAS=1                    # dev/staging: 1，prod: 按负载评估
CPU_REQUEST=100m
CPU_LIMIT=500m
MEM_REQUEST=256Mi
MEM_LIMIT=512Mi
```

当前集群节点规格参考：
```bash
kubectl describe nodes | grep -A5 "Allocatable"
```

## 填写 generate-app.conf 的注意事项

### 注意一：imagePullPolicy

```yaml
# 开发调试时用 Always（每次都拉最新）
imagePullPolicy: Always

# 生产用 IfNotPresent（tag 固定时，避免不必要的拉取）
imagePullPolicy: IfNotPresent
```

使用 `latest` tag 时必须用 `Always`，但**生产环境不建议用 `latest` tag**，应使用具体版本号或 git SHA。

### 注意二：Harbor 镜像拉取 Secret

Deployment 需要引用 Harbor 的 imagePullSecret：
```yaml
imagePullSecrets:
  - name: harbor-registry-secret
```

`harbor-registry-secret` 需要提前部署（`deploy-*/secret/harbor-registry-secret/`），  
且必须在同一 namespace 下。

### 注意三：健康检查探针

liveness 和 readiness probe 的路径需与应用实际暴露的健康检查端点一致。

常见端点（确认私有仓库源码后填写）：
```bash
# NestJS
/api/health    或   /health

# FastAPI
/api/v1/health  或  /healthz

# Next.js
/api/ping
```

初始 `initialDelaySeconds` 要考虑应用启动时间（Python 应用通常需要 15-30s，Node 应用 5-10s）。

### 注意四：ConfigMap / Secret 的 envFrom 引用名称

Deployment template 里通过 `envFrom` 引用 ConfigMap 和 Secret：
```yaml
envFrom:
  - configMapRef:
      name: auth-app-backend-config    # 必须与 ConfigMap 的 metadata.name 一致
  - secretRef:
      name: auth-app-backend-secret    # 必须与 Secret 的 metadata.name 一致
```

`generate-app.conf` 里定义的 ConfigMap/Secret 名称必须与 `generate-*-config.conf` / `generate-*-secret.conf` 里 `OUTPUT_FILE` 生成的资源名一致。

### 注意五：资源限制设置原则

- `request` 是调度保障（Pod 能调度到的最低资源）
- `limit` 是上限（超出则 OOMKilled 或 CPU throttle）
- 不设 `limit` 的 Pod 在节点资源紧张时会被优先驱逐

建议比例：`limit = 2 × request`（给突发流量留余量，又避免无限制占用）。

## 检查清单

- [ ] `IMAGE_TAG` 与最近推送到 Harbor 的 tag 一致
- [ ] `containerPort` 与应用实际监听端口一致
- [ ] `imagePullPolicy` 已按生产规范设置（非 `latest` 时用 `IfNotPresent`）
- [ ] `harbor-registry-secret` 已在目标 namespace 部署
- [ ] 健康检查端点路径已在源码中确认
- [ ] `initialDelaySeconds` 已考虑应用启动时间
- [ ] `envFrom` 里的 ConfigMap/Secret 名称与实际资源名一致
- [ ] `resources.requests/limits` 已设置（不留空）
