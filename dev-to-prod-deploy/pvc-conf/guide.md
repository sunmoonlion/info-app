# pvc-conf — 持久化存储的 Dev → PVC 指南

## PVC 处理什么

本地开发直接用宿主机目录，k8s 里需要 PersistentVolumeClaim（PVC）。  
凡是 `.env` 里出现**文件系统路径**，或源码里有**文件读写操作**，都需要考虑是否需要 PVC。

## 从开发侧哪里找存储需求

### 来源一：`app/.env` 里的路径类字段

扫描 `.env`，找含以下关键词的字段：

```
_PATH    _DIR    _DIRECTORY    _FOLDER    _MOUNT
UPLOAD_  DATA_   STORAGE_      CACHE_     LOG_
```

常见字段：
```
UPLOAD_PATH=/tmp/uploads        → 文件上传目录，需 PVC
DATA_DIR=/home/user/data        → 数据目录，需 PVC
LOG_DIR=/var/log/app            → 日志目录（视情况，有时用 stdout 替代）
CACHE_DIR=/tmp/cache            → 缓存目录（视情况，ephemeral volume 可能足够）
```

### 来源二：源码中的文件操作

搜索私有仓库里的文件写入操作：
```bash
grep -r "open(" app/ | grep -v ".pyc"
grep -r "writeFile\|createWriteStream\|fs.write" app/src/
grep -r "UPLOAD_PATH\|DATA_DIR\|STORAGE" app/
```

找到读写路径后，确认哪些需要在 Pod 重启后保留（需 PVC），哪些是临时的（ephemeral 即可）。

### 来源三：中间件特殊挂载需求

某些组件有固定挂载点（非来自 `.env`）：

| 组件 | 挂载路径 | 说明 |
|------|---------|------|
| Casdoor | `/conf/app.conf` | beego 配置，PVC 覆盖镜像内置文件（见 CASDOOR_DEPLOY_ISSUES 问题9） |
| 应用日志 | `/app/logs` | 如果需要持久化日志 |
| Celery 任务 | `/app/celery-data` | 视任务类型 |

## 填写 generate-*-pvc.conf 的注意事项

### 注意一：存储大小要合理估算

```bash
# generate-*-pvc.conf
STORAGE_SIZE=10Gi     # 上传文件目录
STORAGE_SIZE=1Gi      # 配置目录
STORAGE_SIZE=50Gi     # 数据集目录
```

不要全部填 `1Gi`，也不要盲目填大。根据实际业务估算，可以后续扩容（取决于 StorageClass 是否支持）。

### 注意二：访问模式（accessModes）

| 场景 | accessModes |
|------|------------|
| 单 Pod 读写（默认） | `ReadWriteOnce` |
| 多 Pod 同时读写（如日志聚合） | `ReadWriteMany`（需 StorageClass 支持，如 NFS） |
| 只读挂载 | `ReadOnlyMany` |

当前集群的 StorageClass 支持情况：
```bash
kubectl get storageclass
```

### 注意三：PVC 与 ConfigMap/Secret 的路径字段协调

如果 `.env` 里有 `UPLOAD_PATH=/tmp/uploads`，进 k8s 后：
- **PVC** 挂载到 Pod 的 `/uploads`（在 Deployment template 的 `volumeMount` 里定义）
- **ConfigMap** 里的 `UPLOAD_PATH` 改为 `/uploads`（与挂载点一致）
- **`.env`** 里的 `/tmp/uploads` 仅本地有效，不进 k8s

即：路径值本身（`/uploads`）进 ConfigMap，PVC 的挂载点由 Deployment template 决定，两者必须对齐。

### 注意四：区分需要持久化的目录和临时目录

| 类型 | 说明 | k8s 处理 |
|------|------|---------|
| 用户上传文件 | Pod 重启后必须保留 | PVC |
| 数据库数据 | 通常由中间件自己的 PVC 管理，应用不直接挂载 | 不处理 |
| 临时缓存 | Pod 重启后可以丢弃 | emptyDir（在 Deployment template 里） |
| 配置文件 | 小文件，内容固定 | ConfigMap 挂载（非 PVC） |

## 检查清单

- [ ] 所有需要持久化的目录已识别（上传文件、持久化数据）
- [ ] 每个 PVC 的存储大小已合理估算
- [ ] accessModes 与使用场景匹配（单 Pod 还是多 Pod）
- [ ] Deployment template 的 `volumeMount.mountPath` 与 ConfigMap 里的路径字段值一致
- [ ] 临时目录改用 emptyDir，不浪费 PVC
- [ ] 当前集群 StorageClass 已确认支持所需 accessModes
