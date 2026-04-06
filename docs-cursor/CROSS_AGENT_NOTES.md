# 跨 Agent 互通笔记（CROSS AGENT NOTES）

> 如果同时使用多个 AI 工具（如 Cursor + Claude Code），在此记录各自的发现、决策，方便互相借鉴。

---

## 格式

```
## YYYY-MM-DD — {{来源 Agent}} → {{目标 Agent}}

**发现 / 决策**：
{{一句话描述}}

**背景**：
{{为什么值得记录，对另一个 Agent 有什么参考价值}}
```

---

## 示例

## YYYY-MM-DD — Claude Code → Cursor

**发现**：后端 `/api/v1/users` 返回的 `avatar_url` 字段在某些情况下为 `null`，前端需要做 fallback 处理。

**背景**：Claude Code 在实现用户头像时踩到了这个坑，Cursor 实现相同模块时可以提前处理。
