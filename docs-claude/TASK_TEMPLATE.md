# 任务卡模板

文件命名：`docs-claude/tasks/TASK-XXXX-<slug>.md`

---

```markdown
# TASK-XXXX：<名称>

状态：待开始 / 进行中 / 完成 / 阻塞
日期：YYYY-MM-DD

## 要做什么

一句话说清楚。

## 我会先读哪些后端代码

- `{{backend-repo}}/{{path}}/xxx.py`
- ...

（列出来，避免遗漏；读完后更新 API_CONTRACT.md）

## 会改哪些文件

- `path/to/file.ts`    新建 / 修改
- ...

## 不做什么

明确排除，防止范围蔓延。

## 验收

用户执行这几步后，应该看到什么：
1. ...
2. ...

## 完成记录

改动摘要、实际验证结果、发现的问题（附 ISSUE_LOG 编号）
```

---

## 示例

```markdown
# TASK-0001：登录页面

状态：完成
日期：YYYY-MM-DD

## 要做什么

实现登录页，对接 Casdoor OIDC 登录流程，登录成功后跳转首页。

## 我会先读哪些后端代码

- `{{backend-repo}}/auth/routes.py`

## 会改哪些文件

- `app/pages/login.vue`             新建
- `app/composables/useAuth.ts`      新增 login 方法

## 不做什么

- 不做第三方登录
- 不做记住密码功能

## 验收

1. 访问 /login，页面正常渲染
2. 点击登录，跳转 Casdoor 授权页
3. 授权后跳回应用，已登录状态

## 完成记录

- 接口契约已更新到 API_CONTRACT.md
- 验证全部通过
```
