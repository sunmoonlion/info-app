# Spider MVP Handoff

日期：2026-07-06

本文用于把 `info-app` 的采集与资讯治理 MVP 迁移到另一台机器后继续实施。

## 1. 总体状态

本轮已完成 `info-app` 采集能力的第一版代码骨架和后端 MVP，并已用本机 kind PostgreSQL / Redis 与本地对象存储跑通基础端到端验证。

当前判断：

- 后端代码主体已完成。
- 数据库 migration 已在本机 kind PostgreSQL 执行到 head，并已用普通应用用户在全新临时库验证通过。
- 后端静态检查和单元测试通过。
- 前端最小管理页面已写好，依赖安装、`pnpm type-check` 和 `pnpm build-only` 已通过。
- Elasticsearch/OpenSearch 索引 mapping、写入 adapter、手动重建和 `document_version`
  增量写入已实现；平台认证、CA 和 alias 运行配置已补齐，并已验证真实 alias 写入权限。
- `knowledge-app` ingestion client 已实现为可配置投递；真实 ingestion API 联调尚未完成。
- 完整反爬策略还未实现。

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
# 12 passed

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

结果：

- `pytest`：19 passed
- `pyright`：0 errors
- `compileall`：通过
- `alembic heads`：识别 `20260706_0001`
- 应用导入：通过
- `uv run alembic current`：`20260706_0001 (head)`
- 全新临时库迁移：普通 `info_admin_user` 执行 `uv run alembic upgrade head` 通过，不需要 `uuid-ossp` 扩展权限
- 平台 S3：`STORAGE_BACKEND=s3` crawl job 成功写入 raw/header/clean/text 四类对象到 `development-info-originals`
- 平台 Elasticsearch：使用 Secret/CA 向 `development-info-app-information-write` alias 写入验证文档成功，写入后已删除
- 平台 RabbitMQ/Celery：API 投递 job `a14ebe20-2bf1-422a-8637-fc9178ebff9c`，worker 消费 `app.tasks.crawl_url` 后成功生成 `document_version=947851da-be8a-418b-be86-2d255869eb91`，并继续投递/执行 `app.tasks.index_document_version`
- 本地 API：`POST /api/admin/crawl-jobs/{job_id}/run` 抓取 `http://127.0.0.1:18080/` 成功，返回 `status=succeeded`、`http_status=200`，并生成 `document_id` / `document_version_id`

补充说明：直接抓取 `https://example.com` 在当前本机网络下返回 `ConnectTimeout`，API 已能将其记录为 crawl job 业务失败，不再触发 500。

## 6. 未完成

迁移到另一台机器时优先确认：

1. 准备 PostgreSQL / Redis。
2. 配置 `DATABASE_URL` 和 Redis 连接信息。
3. 执行 `uv run alembic upgrade head`，并确认 `uv run alembic current` 为 `20260706_0001 (head)`。
4. 启动后端。
5. 用可访问 URL 跑一遍 `crawl_job -> document -> artifact` 闭环。
6. 检查本地对象存储或 S3 写入 `raw.html`、`headers.json`、`clean.md`、`text.txt`。

仍未实现：

- Scrapy 真实执行。
- Playwright 真实执行。
- 完整反爬策略引擎。
- 前端完整产品化。
- PDF / Office 真实转换，需要后续对接 `tools-app`。
- 实体/主题关联和摘要评分等治理增强。

已补充但待真实环境验证：

- 删除索引后的手动重建机制。
- 部署新版镜像后在集群内确认 Celery worker 后台采集闭环。
- 配置 `KNOWLEDGE_APP_INGEST_URL` 后调用真实 `knowledge-app` ingestion API。
- `distribution_record` 的失败重试和状态对账。
- 抽取结果人工审核。

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

1. 部署新版后验证应用内 `document_version` 增量索引和 knowledge-app ingestion API。
2. 前端页面产品化小修。
3. Scrapy worker：后端已能导入 crawler worker 产出的 `results` / `links`。
4. Playwright worker：后端已能导入渲染 worker 产出的 `results` / `links`。
5. 治理增强：K1 来源可信度/版权状态、K2 近似重复检测、K3 转载/同源关系标注已完成，下一步可做实体/主题关联。
6. PDF / Office 对接 `tools-app`。

## 8. 当前 Git 变更概览

`/home/zym/info-app` 顶层状态：

```text
 m info-admin-backend
 ? info-admin-frontend
```

后端子模块主要变更：

```text
M  app/.env.example
M  app/alembic/env.py
M  app/app/infrastructure/messaging/celery_producer.py
M  app/app/infrastructure/models/__init__.py
M  app/app/interfaces/endpoints/routes.py
M  app/app/worker.py
M  app/core/config.py
M  app/pyproject.toml
M  app/uv.lock
?? app/alembic/versions/20260706_0001_info_spider_mvp.py
?? app/app/application/collectors/
?? app/app/application/services/info_crawl_service.py
?? app/app/infrastructure/models/info.py
?? app/app/infrastructure/storage/object_storage.py
?? app/app/interfaces/endpoints/info_routes.py
?? app/app/interfaces/schemas/info.py
?? app/app/tasks/crawl.py
?? app/tests/
?? docs/SPIDER_MVP.md
```

前端子模块主要变更：

```text
?? src/pages/info/
```

平台文档变更：

```text
/home/zym/k8s/sunmoonai/app-platform/docs/README.md
/home/zym/k8s/sunmoonai/app-platform/info-app/docs/
```

## 9. 架构边界

- `info-app` 是资讯主系统，保存原始证据和主档。
- `knowledge-app` / RAGFlow 是派生处理，不保存唯一原文。
- `investment-app` 只引用资讯，不复制主档。
- `tools-app` 负责 PDF / Office / OCR 等通用转换能力。
- 当前实现没有直接调用 RAGFlow 私有 API。
