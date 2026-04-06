# docs-claude 文档导航

Claude Code 版项目文档目录。

## 快速找到你要的东西

| 我想... | 去看 |
|--------|------|
| **新对话接续上次工作** | [SESSION_HANDOFF.md](SESSION_HANDOFF.md) ← 最先读 |
| 确认要做哪些页面、路由、组件 | [FRONTEND_PLAN.md](FRONTEND_PLAN.md) |
| 了解项目整体目标和边界 | [PROJECT_CHARTER.md](PROJECT_CHARTER.md) |
| 知道接下来做什么 | [ROADMAP.md](ROADMAP.md) |
| 搭环境、启动服务 | [ENV_BASELINE.md](ENV_BASELINE.md) |
| 查某个接口的参数和响应格式 | [API_CONTRACT.md](API_CONTRACT.md) |
| 了解我的工作流程 | [DELIVERY_WORKFLOW.md](DELIVERY_WORKFLOW.md) |
| 查历史决策（某事为什么这么做） | [DECISION_LOG.md](DECISION_LOG.md) |
| 记录或查看已知问题 | [ISSUE_LOG.md](ISSUE_LOG.md) |
| 联调验证某个功能 | [TEST_CHECKLIST.md](TEST_CHECKLIST.md) |
| 创建新任务卡 | [TASK_TEMPLATE.md](TASK_TEMPLATE.md) |
| 看变更历史 | [CHANGELOG.md](CHANGELOG.md) |
| 查两个 Agent 互相借鉴了什么 | [CROSS_AGENT_NOTES.md](CROSS_AGENT_NOTES.md) |

## 规则文件

CLAUDE.md（根目录）始终被加载。进入子目录时叠加对应的 CLAUDE.md。

```
/CLAUDE.md                    全局上下文
/{{frontend-repo}}/CLAUDE.md  前端上下文（按需创建）
/{{backend-repo}}/CLAUDE.md   后端上下文（按需创建）
```
