# Spider MVP Handoff

> 历史实施快照，最后有效日期为 2026-07-10。它用于审计 Spider MVP 的实现与验证，不是当前路线图、部署状态或恢复入口；当前计划以 k8s 仓库的 MoocManus v5 方案、实施计划和交接文档为准。

日期：2026-07-07

更新：2026-07-09，已在 `codex-1` 恢复并完成 KIND 部署验证。

## 0. 暂停交接快照

本轮先暂停，不再继续部署或扩功能。代码已由用户推送到 Gitee 的
`codex-1` 分支；下次恢复时以远端 `codex-1` 为准同步。

已推送的分支头：

```text
info-admin-backend   55bf97c
info-admin-frontend  a40d0b2
info-app             23b0f5f
k8s                  984c636
```

当前建议不要在没有准备好验证窗口时直接部署。恢复时优先做：

1. 同步四个仓库到 `codex-1`。
2. 重新跑后端 `uv run pytest`、`uv run pyright`，必要时跑前端 `pnpm type-check` / `pnpm build-only`。
3. 选择合适时间构建并部署新版镜像到 KIND。
4. 在集群内执行/确认 Alembic migration 到 head。
5. 用平台 PostgreSQL、S3、RabbitMQ、Elasticsearch 跑一遍端到端采集、索引和治理 API smoke test。

2026-07-09 恢复结果：

- 后端 `uv run pytest` 通过：36 passed。
- 后端 `uv run pyright` 通过：0 errors。
- 前端 `pnpm type-check` 和 `pnpm build-only` 通过。
- `deploy-info-app-all.sh --cluster KIND validate-resources` 通过。
- `info-admin-backend:1.0.1` 已构建并推送到 Harbor；最终 digest 为
  `sha256:543b03956d718cdfb57c8fc4af2fd81252ceecb7ee544cf858802d552bafc20a`。
- `info-admin-frontend:1.0.1` 已用标准多阶段 Dockerfile 构建并推送到 Harbor；digest 为
  `sha256:36c4d4f96febbe240ec7c0b979b90c427b0bf239e40259989f04bc7f790ca0cf`。
- KIND 当前 `info-admin-backend`、`celeryworker-info-admin-backend`、`info-admin-frontend` 均运行 `1.0.1`；web 侧组件保持 `1.0.0`。
- 集群内 Alembic `upgrade head` 和 `current` 通过，当前版本为 `20260707_0002 (head)`。
- 部署态 smoke 通过：创建 source、上传 Markdown、S3 artifact 查询、document/version 查询、document review、entity-links、summary-profile、version review、Elasticsearch alias rebuild 全部成功。
- smoke 样本：`source_code=codex-smoke-ea535169`，`document_id=6123db9b-a6cc-4503-bfb2-dce516ed1a41`，`version_id=7d425744-0ed1-4b91-831d-ca5253f6ce20`，artifact 数量 15，`development-info-app-information-write` 重建 indexed=5、failed=0。

2026-07-10 收尾验证：

- `info-admin-frontend:1.0.1` 运行中镜像 digest 为 `sha256:3ce28192f97bd38a46d47b3bc357b9d826f219cff79fa47bd05dbdb84180bc98`，容器静态产物已确认包含“批量审核 / 审计 / 分发详情”等本轮治理工作台 UI。
- KIND 中 `info-admin-backend-config` / `info-admin-backend-secret` 已应用 `KNOWLEDGE_APP_INGEST_URL`、`KNOWLEDGE_APP_TIMEOUT_SECONDS`、`KNOWLEDGE_APP_API_KEY`，并已重启 `info-admin-backend` 与 `celeryworker-info-admin-backend`。
- 后端 ConfigMap 确认：`KNOWLEDGE_APP_INGEST_URL=http://knowledge-admin-backend:8000/api/knowledge/ingestions`、`KNOWLEDGE_APP_TIMEOUT_SECONDS=20`。
- 集群内 Alembic `upgrade head` / `current` 通过，当前版本仍为 `20260707_0002 (head)`。
- 部署态 smoke 通过：创建 source、Markdown 上传、document/version/artifact 查询、document review、entity-links、summary-profile、Knowledge distribution 创建与真实 `knowledge-app` ingestion API 投递全部成功。
- smoke 样本：`source_code=codex-smoke-496e04fd`，`document_id=a27eba8b-20db-463b-b75e-6f3c49d53d35`，`version_id=ef23fdc1-eaa9-436d-a9c6-b7eb67ae0870`，`distribution_id=d6c57bb3-786e-4d8c-be81-bff3cf6d54ac`，artifact 数量 3，audit_log 数量 3。
- 真实 ingestion smoke：`distribution_id=bcaad877-ee79-4aca-ba1b-b115480098b8`，`target_dataset=codex-smoke-v2`，`distribution_record.status=succeeded`，`knowledge_ingestion_job.id=ed88d1a0-c339-430b-83af-8d1cdcbfd0cd`，`knowledge_ingestion_job.status=accepted`。

本文用于把 `info-app` 的采集与资讯治理 MVP 迁移到另一台机器后继续实施。

## 1. 总体状态

本轮已完成 `info-app` 采集能力的第一版代码骨架和后端 MVP，并已用本机 kind PostgreSQL / Redis 与本地对象存储跑通基础端到端验证。

当前判断：

- 后端代码主体已完成。
- 数据库 migration 已在本机 kind PostgreSQL 执行到 head，并已用普通应用用户在全新临时库验证通过；当前 head 包含 `20260707_0002_source_governance`。
- 后端静态检查和单元测试通过。
- 前端最小管理页面已写好，依赖安装、`pnpm type-check` 和 `pnpm build-only` 已通过。
- KIND 部署验证已恢复完成；admin API、Celery worker、admin frontend 已更新到 `1.0.1`。
- Elasticsearch/OpenSearch 索引 mapping、写入 adapter、手动重建和 `document_version`
  增量写入已实现；平台认证、CA 和 alias 运行配置已补齐，并已验证真实 alias 写入权限。
- `knowledge-app` ingestion client 已实现为可配置投递；真实 ingestion API 联调已完成，info-app 标准 payload 可被 knowledge-app 接收并返回 `202 Accepted`。
- 来源治理、重复候选、转载关系、实体关联、摘要画像和统一审计日志已完成后端 MVP；前端已补治理/画像/Knowledge 分发工作台，并支持状态筛选、批量审核、审计时间线和分发详情。
- 完整反爬策略、真实 Scrapy/Playwright 执行、PDF/Office 转换仍待后续阶段。

## 2. 相关路径

业务源码：

```text
/home/zym/info-app
```

后端：

```text
/home/zym/info-app/info-admin-backend/app
```

前端：

```text
/home/zym/info-app/info-admin-frontend
```

平台架构和任务文档：

```text
/home/zym/k8s/sunmoonai/app-platform/info-app/docs/info-app-spider-architecture.md
/home/zym/k8s/sunmoonai/app-platform/info-app/docs/info-app-spider-implementation-tasks.md
/home/zym/k8s/sunmoonai/app-platform/info-app/docs/spider-reference/
```

后端运行说明：

```text
/home/zym/info-app/info-admin-backend/docs/SPIDER_MVP.md
```

## 3. 已完成

### 3.1 数据模型与 Migration

新增模型：

```text
info-admin-backend/app/app/infrastructure/models/info.py
```

包含：

- `info_source`
- `info_collector`
- `crawl_job`
- `raw_artifact`
- `info_document`
- `info_document_version`
- `extracted_content`
- `distribution_record`

Migration：

```text
info-admin-backend/app/alembic/versions/20260706_0001_info_spider_mvp.py
```

### 3.2 后端服务

核心服务：

```text
info-admin-backend/app/app/application/services/info_crawl_service.py
```

已实现：

- 信息源创建和查询。
- Collector 创建、查询和发现。
- URL 采集任务。
- 静态 HTML 抓取。
- 原始响应保存。
- `trafilatura` 正文抽取。
- 文本 / HTML / Markdown 上传入库。
- PDF / Office 上传后标记 `pending_tool_processing`。
- 同 URL 同内容不重复生成版本。
- 内容变化生成新的 `document_version`。
- 抽取失败保留原始证据，并生成 `extraction_status=extraction_failed` 的版本。
- Artifact 元数据查询。
- 基础标题 / URL 查询。
- 文档和抽取版本审核状态调整，审核记录写入 `metadata_json.review_history`。
- `knowledge-app` 分发记录和 payload 生成。

### 3.3 对象存储

新增：

```text
info-admin-backend/app/app/infrastructure/storage/object_storage.py
```

支持：

- `STORAGE_BACKEND=local`
- `STORAGE_BACKEND=s3`

K8S `info-admin-backend-config` 默认启用 `STORAGE_BACKEND=s3`；
Celery worker 会继承业务 PostgreSQL、Redis、S3、Elasticsearch 配置。

已用本机 kind MinIO/AIStor 验证 `STORAGE_BACKEND=s3`：HTML crawl job 成功写入
`raw.html`、`headers.json`、`clean.md`、`text.txt` 四类 artifact 到
`development-info-originals`，并记录对象 `version_id`。

本地默认写入：

```text
info-admin-backend/app/.local-storage/info-originals/development-info-originals/
```

### 3.4 Collector Adapter

新增目录：

```text
info-admin-backend/app/app/application/collectors/
```

已实现：

- `rss` / `atom`
- `api`
- `changedetection`

已提供占位：

- `scrapy`
- `playwright`

### 3.5 API

主要 API：

```text
POST /api/admin/sources
GET  /api/admin/sources

POST /api/admin/collectors
GET  /api/admin/collectors
POST /api/admin/collectors/{collector_id}/discover

POST /api/admin/crawl-jobs
GET  /api/admin/crawl-jobs/{job_id}
POST /api/admin/crawl-jobs/{job_id}/run
GET  /api/admin/crawl-jobs/{job_id}/artifacts

POST /api/admin/uploads

GET  /api/documents
GET  /api/documents/{document_id}
GET  /api/documents/{document_id}/versions
GET  /api/documents/{document_id}/artifacts
GET  /api/documents/{document_id}/versions/{version_id}/artifacts
POST /api/documents/{document_id}/review
POST /api/documents/{document_id}/versions/{version_id}/review

GET  /api/artifacts/{artifact_id}

POST /api/admin/distributions/knowledge
```

### 3.6 Celery

新增：

```text
info-admin-backend/app/app/tasks/crawl.py
```

任务名：

```text
app.tasks.crawl_url
```

未配置 `CELERY_BROKER_URL` 时，可用同步调试接口：

```text
POST /api/admin/crawl-jobs/{job_id}/run
```

### 3.7 前端

新增最小管理页：

```text
info-admin-frontend/src/pages/info/crawl.vue
```

页面覆盖：

- 手动 URL 任务。
- 信息源创建。
- Collector 创建。
- Collector discover。
- 文件上传。
- Document 列表查询。
- Document 状态筛选和多选批量审核。
- 文档审核、实体链接、摘要画像治理。
- Knowledge 分发记录创建、投递、失败重试、状态筛选和 payload / 错误详情查看。
- 治理审计日志时间线展示。

验证：已安装前端依赖，`pnpm type-check` 和 `pnpm build-only` 通过。

### 3.8 测试

新增测试：

```text
info-admin-backend/app/tests/test_collectors.py
info-admin-backend/app/tests/test_object_storage.py
info-admin-backend/app/tests/test_review_helpers.py
info-admin-backend/app/tests/test_upload_helpers.py
```

当前通过：

```bash
uv run pytest
# 36 passed

uv run pyright
# 0 errors
```

## 4. 依赖变更

后端新增依赖：

```text
boto3
trafilatura
python-multipart
```

已更新：

```text
info-admin-backend/app/pyproject.toml
info-admin-backend/app/uv.lock
```

另一台机器应先执行：

```bash
cd /home/zym/info-app/info-admin-backend/app
uv sync --frozen
```

## 5. 已验证

在当前机器已执行并通过：

```bash
cd /home/zym/info-app/info-admin-backend/app
uv sync --frozen
uv run pytest
uv run pyright
python3 -m compileall app core tests
uv run alembic heads
uv run alembic upgrade head --sql
uv run python -c "from app.main import app; print(len(app.routes))"
```

最新结果：

- `pytest`：36 passed
- `pyright`：0 errors
- 前端 `pnpm type-check`：通过
- 前端 `pnpm build-only`：通过
- `compileall`：通过
- `alembic heads`：识别当前 head，包含 `20260707_0002_source_governance`
- 应用导入：通过
- `uv run alembic current`：已验证到 head
- 全新临时库迁移：普通 `info_admin_user` 执行 `uv run alembic upgrade head` 通过，不需要 `uuid-ossp` 扩展权限
- 平台 S3：`STORAGE_BACKEND=s3` crawl job 成功写入 raw/header/clean/text 四类对象到 `development-info-originals`
- 平台 Elasticsearch：使用 Secret/CA 向 `development-info-app-information-write` alias 写入验证文档成功，写入后已删除
- 平台 RabbitMQ/Celery：API 投递 job `a14ebe20-2bf1-422a-8637-fc9178ebff9c`，worker 消费 `app.tasks.crawl_url` 后成功生成 `document_version=947851da-be8a-418b-be86-2d255869eb91`，并继续投递/执行 `app.tasks.index_document_version`
- 本地 API：`POST /api/admin/crawl-jobs/{job_id}/run` 抓取 `http://127.0.0.1:18080/` 成功，返回 `status=succeeded`、`http_status=200`，并生成 `document_id` / `document_version_id`

补充说明：直接抓取 `https://example.com` 在当前本机网络下返回 `ConnectTimeout`，API 已能将其记录为 crawl job 业务失败，不再触发 500。

## 6. 未完成 / 暂停点

恢复时优先确认：

1. 先不要假设 git push 已经更新运行中服务；当前集群仍可能跑旧镜像。
2. 选择合适窗口后，用 `~/master/k8s/sunmoonai/app-platform/info-app/deploy-info-app-all.sh --cluster KIND` 构建/部署新版镜像。
3. 执行或确认集群 Alembic migration 到 head。
4. 用可访问 URL 跑一遍 `crawl_job -> document_version -> search index -> governance metadata` 闭环。
5. 检查平台 S3 写入 `raw.html`、`headers.json`、`clean.md`、`text.txt`。
6. 检查 RabbitMQ worker 是否继续消费 `app.tasks.crawl_url` 和 `app.tasks.index_document_version`。

仍未实现：

- Scrapy 真实执行。
- Playwright 真实执行。
- 完整反爬策略引擎。
- 前端完整产品化：治理工作台主线已补齐，后续可继续打磨交互密度、批量失败回滚提示、分发对账可视化和更细的空/错/加载态。
- PDF / Office 真实转换，需要后续对接 `tools-app`。

已补充并通过真实环境验证：

- 配置非空 `KNOWLEDGE_APP_INGEST_URL` 后调用真实 `knowledge-app` ingestion API。
- `distribution_record` 对真实 `knowledge-app` 的成功状态对账。

仍待后续产品化验证：

- `distribution_record` 对真实 `knowledge-app` 的失败重试和错误详情对账。
- 治理操作的前端完整产品化：主流程已补，后续补真实运行数据下的体验调优和更细的错误态。

## 7. 下一台机器建议步骤

### Step 1：同步代码

确认同步：

```text
/home/zym/info-app
/home/zym/k8s/sunmoonai/app-platform/info-app/docs
```

### Step 2：后端依赖和检查

```bash
cd /home/zym/info-app/info-admin-backend/app
uv sync --frozen
uv run pytest
uv run pyright
```

### Step 3：准备数据库

设置 `.env` 或环境变量：

```text
DATABASE_URL=postgresql://info:info@localhost:5432/info
```

执行：

```bash
uv run alembic upgrade head
```

### Step 4：启动后端

```bash
uv run uvicorn app.main:app --host 0.0.0.0 --port 8000
```

### Step 5：跑最小闭环

创建 URL 任务：

```bash
curl -X POST http://localhost:8000/api/admin/crawl-jobs \
  -H 'Content-Type: application/json' \
  -d '{"target_url":"https://example.com","enqueue":false}'
```

同步执行：

```bash
curl -X POST http://localhost:8000/api/admin/crawl-jobs/{job_id}/run
```

查询：

```bash
curl http://localhost:8000/api/admin/crawl-jobs/{job_id}
curl http://localhost:8000/api/documents
```

### Step 6：前端依赖和验证

```bash
cd /home/zym/info-app/info-admin-frontend
pnpm install
pnpm type-check
pnpm build-only
```

如镜像源超时，可切换 registry 后重试。

### Step 7：继续开发

建议下一步优先级：

1. 前端治理页面用真实数据回归：批量审核、审计时间线、分发状态筛选、错误详情和失败重试。
2. knowledge-app ingestion 后续接入真实解析 / chunk / RAGFlow 索引 worker，并把 `accepted` 推进到 `running/succeeded/failed`。
3. Scrapy worker：后端已能导入 crawler worker 产出的 `results` / `links`。
4. Playwright worker：后端已能导入渲染 worker 产出的 `results` / `links`。
5. 治理增强：K1-K6 已完成，后续可产品化前端治理操作。
6. PDF / Office 对接 `tools-app`。

## 8. 当前 Git 状态

截至 2026-07-10，本轮 `info-app` 收尾代码与配置已推送到 `origin/codex-1`，随后又追加了本文档的部署态 smoke 记录。相关分支头以各仓库当前提交为准，核心子仓当前头包括：

```text
info-admin-backend   bc05d00
info-admin-frontend  fd3a943
k8s                  d8b193c
```

本文档提交后，如需远端留痕，只需要推送 `info-app` 父仓 `codex-1`。

## 9. 架构边界

- `info-app` 是资讯主系统，保存原始证据和主档。
- `knowledge-app` / RAGFlow 是派生处理，不保存唯一原文。
- `investment-app` 只引用资讯，不复制主档。
- `tools-app` 负责 PDF / Office / OCR 等通用转换能力。
- 当前实现没有直接调用 RAGFlow 私有 API。
