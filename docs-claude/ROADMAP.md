# 路线图（ROADMAP）

## 阶段总览

```
Phase 0  治理基线        ░░░░░░░░░░  待开始
Phase 1  主链路联调      ░░░░░░░░░░  待开始
Phase 2  稳定化          ░░░░░░░░░░  待开始
Phase 3  升级规划        ░░░░░░░░░░  待开始
```

---

## Phase 0：治理基线

**目标**：建立 Claude Code 协作所需的规则、文档、流程基础设施。

**关键产物**：

- [ ] `/CLAUDE.md`（全局规则）
- [ ] `docs-claude/PROJECT_CHARTER.md`
- [ ] `docs-claude/ROADMAP.md`
- [ ] `docs-claude/ENV_BASELINE.md`
- [ ] `docs-claude/DELIVERY_WORKFLOW.md`
- [ ] `docs-claude/API_CONTRACT.md`（初始骨架）
- [ ] `docs-claude/DECISION_LOG.md`
- [ ] `docs-claude/ISSUE_LOG.md`
- [ ] `docs-claude/TEST_CHECKLIST.md`
- [ ] `docs-claude/TASK_TEMPLATE.md`
- [ ] `docs-claude/CHANGELOG.md`

**验收标准**：文档可独立指导新成员上手；规则可被 Claude Code 正确加载。

---

## Phase 1：主链路联调

**目标**：跑通核心业务链路（登录 → 主要功能 → 数据真实来自后端）。

**模块推进顺序**：

1. **登录鉴权** — OIDC 流程、Token 存储、未登录跳转守卫
2. **{{核心模块 1}}** — {{简要描述}}
3. **{{核心模块 2}}** — {{简要描述}}
4. **{{核心模块 3}}** — {{简要描述}}

**验收标准**：
- 主链路可端到端演示
- 冒烟清单（见 TEST_CHECKLIST.md）全部通过

---

## Phase 2：稳定化

**目标**：降低回归风险，提升可维护性与文档完整性。

**关键动作**：
- 扩展回归清单（覆盖错误路径）
- 收敛高频错误与边界 case
- 完善 API_CONTRACT.md（补全所有用到的接口）

**验收标准**：连续两轮回归无阻断性问题；文档完整到足以支撑交接。

---

## Phase 3：升级规划

**目标**：在可运行基线基础上，规划并实施依赖升级或架构改进。

**原则**：单独立项，不混入功能开发；分步验证，每步有明确回退方案。

**前置条件**：Phase 2 已完成，主链路稳定。

---

## 里程碑

| 里程碑 | 含义 | 目标日期 |
|--------|------|---------|
| M0 | 治理文档闭环，规则可加载 | YYYY-MM-DD |
| M1 | 主链路端到端可演示 | YYYY-MM-DD |
| M2 | 稳定回归，文档可支撑交接 | YYYY-MM-DD |
| M3 | 升级/改进方案评审通过 | YYYY-MM-DD |

---

## 变更规则

路线图变更必须同步：
- `DECISION_LOG.md`（决策原因）
- `CHANGELOG.md`（变更记录）
