# 变更日志（CHANGELOG）

> 记录项目重大变更，按时间倒序排列。
> 每次 Phase 推进、架构变更、重大决策落地时更新。

---

## [Unreleased]

### Added
- 初始化 `docs-cursor/` 文档体系
- `info-app -> knowledge-app` 真实 ingestion smoke 已通过：info 标准 payload 投递到 `knowledge-admin-backend`，`distribution_record.status=succeeded`，knowledge ingestion job 返回 `202 Accepted`。

### Changed
- `SPIDER_MVP_HANDOFF.md` 更新真实 knowledge ingestion 联调状态，移除“尚未完成”的过期描述。

---

## 格式说明

```
## [版本或日期] — YYYY-MM-DD

### Added     新增功能或文档
### Changed   变更（非破坏性）
### Fixed     修复
### Removed   删除
### Breaking  破坏性变更（影响接口、数据结构、部署方式）
```
