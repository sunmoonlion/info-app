# 决策日志（DECISION LOG）

> 记录项目关键决策，说明「为什么这么做」，避免后续反复讨论。

---

## DEC-001：后端代码是接口契约的唯一真实来源

- 日期：YYYY-MM-DD
- 状态：Accepted

**决策**：前端开发前必须读后端代码确认接口，不依赖口头约定或推测；提取结果记录在 `API_CONTRACT.md`。

**原因**：项目没有 Swagger/OpenAPI 文档，或文档可能滞后；读代码是最准确的方式。

**影响**：前端开发增加「读代码」步骤，但可避免联调阶段大量接口不匹配的问题。

---

## DEC-002：认证统一使用 Casdoor OIDC，不自建

- 日期：YYYY-MM-DD
- 状态：Accepted

**决策**：所有业务应用接入 Casdoor 作为统一认证中心，不在业务后端自建 JWT 签发逻辑。

**原因**：平台统一认证，避免各应用各自维护 auth 孤岛；Casdoor 支持标准 OIDC/OAuth2，生态成熟。

**影响**：业务后端只做 token 验证（通过 session_id 查 Redis），不负责登录流程。

---

## DEC-003：Token 存储采用 HTTP-only Cookie + Redis Session

- 日期：YYYY-MM-DD
- 状态：Accepted

**决策**：access_token 存储在服务端 Redis，客户端只持有 `session_id`（HTTP-only Cookie），不直接暴露 token。

**原因**：防止 XSS 窃取 token；服务端可随时吊销 session，安全可控。

**影响**：需要 Redis；BFF 或后端必须实现 session 管理逻辑。

---

## DEC-00N：{{决策标题}}

- 日期：YYYY-MM-DD
- 状态：Accepted / Rejected / Superseded

**决策**：{{一句话描述决策内容}}

**原因**：{{为什么这么决定}}

**影响**：{{对代码/流程/团队的影响}}

**触发重审**：{{什么情况下这个决策需要重新评估}}
