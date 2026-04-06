# API 契约（API CONTRACT）

> 从后端代码中提取的接口定义，是前后端联调的唯一真实来源。
> 每次新增接口时在此更新，不依赖口头约定或推测。

---

## 约定

- Base URL：`{{API_BASE_URL}}`，e.g. `http://localhost:8000`
- 认证：`Authorization: Bearer <token>` 或 HTTP-only Cookie `session_id`
- 响应格式：`{ "code": 0, "message": "ok", "data": {...} }`
- 错误响应：`{ "code": <非0>, "message": "<错误描述>" }`

---

## 认证模块

### GET /auth/login
重定向到 OIDC 授权页。

**参数**：无

**响应**：302 → Casdoor authorize URL

---

### GET /auth/callback
OIDC 回调，交换 code 获取 token，写入 session。

**参数**（Query）：
- `code` string 必填

**响应**：302 → `/dashboard`（成功）或 400（失败）

---

### GET /auth/logout
清除 session，退出登录。

**响应**：302 → `/login`

---

### GET /auth/me
获取当前登录用户信息。

**响应**：
```json
{
  "id": "string",
  "name": "string",
  "email": "string",
  "avatar": "string"
}
```

---

## {{业务模块 1}}

### GET /{{path}}
{{描述}}

**参数**：

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `{{field}}` | string | 是 | {{说明}} |

**响应**：
```json
{
  "{{field}}": "{{type}}"
}
```

---

## 错误码

| code | 含义 |
|------|------|
| 0 | 成功 |
| 400 | 请求参数错误 |
| 401 | 未登录 |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |
