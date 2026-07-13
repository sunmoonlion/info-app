# info-app 文档入口

状态：当前有效

本目录是 info-app 根仓唯一的工具无关文档入口。当前跨仓架构、任务顺序和 Gate 以 `k8s` 仓库的 MoocManus v5 总体方案、实施计划、ADR、contracts 和 evidence 为准。

## 本仓真相源

1. Info 后端路由/OpenAPI、数据库 migration、领域模型和自动化测试。
2. Info 前端实际路由、typed client、组件测试和部署配置。
3. k8s 中的 Info desired state、镜像 digest、迁移/回滚证据。
4. `docs/history/` 只保存带日期的历史实施快照，不得作为当前恢复入口。

## 当前历史资料

- [Spider MVP 交接快照](history/SPIDER_MVP_HANDOFF_20260710.md)：仅供审计 2026-07-10 前的实现和验证。

项目事实不得再按 Claude、Cursor、Codex 或其他 AI 工具分别复制。跨仓 Artifact、Identity、Retrieval/Citation 契约不得在本目录创建第二份真相源。
