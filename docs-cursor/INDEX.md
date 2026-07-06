# 文档导航（INDEX）

本页是项目文档总入口，建议固定作为新人阅读起点。

## 一、先读什么（30 分钟上手路径）

1. `PROJECT_CHARTER.md`（5 分钟）
   - 了解项目定位、目标边界、成功标准。
2. `ROADMAP.md`（5 分钟）
   - 了解当前阶段、里程碑、下一步方向。
3. `ENV_BASELINE.md`（8 分钟）
   - 了解环境基线、依赖与启动顺序。
4. `DELIVERY_WORKFLOW.md` + `TASK_TEMPLATE.md`（7 分钟）
   - 了解任务如何拆、如何验收、如何记录。
5. `TEST_CHECKLIST.md`（5 分钟）
   - 了解最小联调与回归标准。

## 二、文档分组

### 1) 项目总纲与规划

- `PROJECT_CHARTER.md`：项目宪章与总原则
- `ROADMAP.md`：阶段路线图与里程碑

### 2) 过程与交付

- `DELIVERY_WORKFLOW.md`：任务执行流程与门禁
- `TASK_TEMPLATE.md`：标准任务卡模板
- `CHANGELOG.md`：关键变更记录

### 3) 技术与质量

- `ENV_BASELINE.md`：环境与依赖基线
- `RUNBOOK.md`：可执行操作手册（启动/排查步骤）
- `API_CONTRACT.md`：接口契约
- `SPIDER_MVP_HANDOFF.md`：采集 MVP 交接文档（完成、未完成、迁移后续步骤）
- `TEST_CHECKLIST.md`：联调与回归清单

### 4) 治理与共识

- `GLOSSARY.md`：术语统一
- `DECISION_LOG.md`：关键决策依据
- `RISK_REGISTER.md`：风险登记与状态
- `ISSUE_LOG.md`：已知问题追踪
- `CROSS_AGENT_NOTES.md`：跨 AI 工具互通笔记

## 三、使用约定

- 每次开始任务前：先创建或更新任务卡（`TASK_TEMPLATE.md`）。
- 每次任务完成后：更新 `CHANGELOG.md` 与相关文档。
- 当路线、原则、风险有变化时：同步更新 `ROADMAP.md` / `DECISION_LOG.md` / `RISK_REGISTER.md`。

## 四、推荐协作节奏

- 日初：确认任务目标与验收标准。
- 日中：记录阻塞与风险变化。
- 日终：沉淀结果（改动、验证、遗留、下一步）。
