# Info 模板对齐：可靠投递开发候选

日期：2026-09-11；模板公共投递基线 `tpl-backend@b667a41`，另包含本轮先在模板
通过验证的开发镜像标签保护。本文是源码接入与开发验证报告，不是正式发布批准。

## 全量比对范围

按 Git 跟踪及非忽略新增文件逐路径比较 Backend、Admin Frontend、Web Frontend，
不包含依赖、构建输出和凭据。两边各有 SHA-256；仅自动替换 tpl/Tpl/TPL 身份字符，
其余差异人工分类，没有使用模板覆盖领域文件。

| 组件 | 完全一致 | 身份归一后相同 | 其它同路径差异 | Info 独有 | 模板独有 |
| --- | --- | --- | --- | --- | --- |
| Backend | 114 | 9 | 33 | 47 | 3 |
| Admin Frontend | 104 | 11 | 10 | 4 | 0 |
| Web Frontend | 82 | 12 | 7 | 0 | 0 |

清单和可复现脚本保存在接手证据目录 `handoff-durable-delivery-luna-20260911/`
的 `info-source-alignment.json`、`audit-source-alignment.py`。清单记录候选内容，
不把脏工作区 HEAD 当作完整源码版本；最终子仓提交列在父仓
`development-source-lock.json`，其中 commit/tree 均取自干净子仓，并已推送独立开发分支。

公共投递的以下 8 份文件与模板逐字一致：`durable_tasks.py`、
`messaging/durable_delivery.py`、`delivery_schema.py`、`repositories/outbox.py`、
`tasks/durable_delivery.py`、`cli/durable_delivery.py`、`delivery_runtime_probe.py`、
`test_durable_delivery_db.py`。认证、授权、错误、日志、审计和公共 UI 未分叉新实现。

## 差异分类与处置

| 类别 | 路径组及说明 | 处置 |
| --- | --- | --- |
| 领域扩展 | collectors、info_crawl_service、Knowledge client、Info ORM、search/storage、info_routes/schema、领域单元测试；Admin 采集页、面板、Info API 客户端、导航和翻译 | 保留；经已有扩展点注册，不把业务写入模板 |
| 领域扩展 | delivery_handlers、models/__init__、http/routes、领域依赖及 uv.lock、dormant/kernel 不变量 | 三个 topic、同一个 Backend、同一组应用服务；保留模板约束并扩展实例断言 |
| 领域扩展 | Info 7 条历史迁移替代模板 3 条迁移 | 保留本 App 线性历史；新迁移调用公共 DDL，不拼接模板 revision 链 |
| 配置 | CLAUDE 身份/领域说明、bootstrap 包名/title、core/config、env.example、认证/配对测试中的 App/scope/cookie、前端 env/server-schema | 身份映射和领域配置；测试夹具的固定虚拟 audience 仍一致保留，不误当生产身份 |
| 配置 | db-access-bootstrap config、search/storage access.json、资源说明、各组件 mybuild 名称/路径 | 独立库、角色、桶、索引、App origin；不复制线上凭据或上线候选 |
| 配置 | CELERY、SPIDER_MVP、可靠投递和构建 README | 更新排队语义、迁移回滚、实际路径和开发标签；保留领域接入文档 |
| 暂时兼容 | 旧 delivery_outbox 服务名、drain CLI、crawl/distribution/search 任务与 worker 注册 | 委托公共层或显式拒绝旧执行；无第二套投递真源；观察窗及旧调用方清点结束后移除，不能先删回滚资产 |
| 暂时兼容 | UUIDMixin 的 Python uuid4 默认；pyproject 中已有 E501/B008/UP046 例外 | 保留 Info 对象构造语义和既有领域 lint 基线，不更改公共投递文件；本轮未宣称完成全仓风格重构 |
| 暂时兼容 | Redis 驱动额外 ACL SAVE；前端 TPL_SSR_* 变量名 | 保留环境持久化约定及模板脚本接口。已删除无消费者的 ADMIN_FRONTEND/WEB_FRONTEND/INFO_SSR 影子配置；不是两套生效配置 |
| 暂时兼容 | Admin lib/info/api.ts 与 lib/info-api.ts；Web 空 Dashboard 翻译节点 | 既有 UI 存量，当前面板使用 lib/info-api.ts；本轮不以公共能力同步为由清空领域 UI，未声称已经清除所有历史未用 API |
| 违规漂移（已修正） | Redis 缺少模板 resetchannels；Backend rebuild 使用 1.0.0；构建文档过时 | 同步模板频道重置；改开发标签；修正文档 |
| 违规漂移（模板先修） | 模板/实例本地构建、推送可覆盖 1.0.0 / 2.0.0 | 模板三个组件先增加保护并验证，再同步 Info；拒绝发生在 registry/凭据访问前 |

本次同步保留上述显式兼容项，不把“完整比对”解释为“所有文件必须相同”。Redis CLI
既有的服务端错误传播、ACL SAVE 在无 ACL 文件时的持久化行为未在本轮整改，属于
既有工具风险；频道权限回归不能证明它们已经解决。

## 验证及边界

- Backend：128 passed（含真实 PostgreSQL、共享契约、租约丢失/取消、原子排队、
  非空数据迁移回滚再升级），Ruff/format/Pyright 通过。
- Admin：44 单元、10 配对浏览器；Web：48 单元、7 配对浏览器；两端完整 check/build
  通过。配对使用后端夹具；本轮前端源码未改，后续仅修改构建脚本和说明。
- 真实 Casdoor：Admin/Web 均验证匿名、登录、跨分面拒绝、CSRF、退出、会话撤销。
  TLS 校验开启；回调截获交给候选进程内 ASGI，DB/Redis 隔离。这不是完整部署态
  前后端 TLS 或浏览器领域操作验收。
- KIND 最终镜像：全新测试库、独立 MQ 队列，独立迁移入口及真实 Worker/Beat，
  重复投递计数和 Inbox 均为 1。测试镜像 manifest 为
  `sha256:0b31bdc27ee97261362015eb149a85a02e9fe549639b9e3125eb634e20abcb18`。
- 备份恢复：此前同迁移源码的完整测试库实际恢复，新库 counter/outbox/inbox=1/1/1。
- Calico v3.28.2 独立集群：内部/前端到 Backend 放行，无标签拒绝；仅 Worker 可达
  Knowledge。首次允许探针失败原因未证实；保留失败记录，第二次全量通过。
- 六个组件的开发脚本均验证正式标签拒绝；隔离 Redis 验证本地和生成的 k8s 客户端
  命令收回旧频道授权、保留目标频道。未验证 ACL 重启持久化。

正式镜像清单与现有部署 bundle 仍是历史发布证据，未改写成候选镜像。开发源码锁
明确 `formal_release=false`，不能替代发布锁。Info 后端 `6f5bffc`、Admin `04ae25c`、
Web `f3ebbc3` 已推送 `luna/durable-delivery-20260911-local`，供父仓固定 gitlink。
跨 App 最终收口尚未完成；不能只凭本文宣称 master 或所有 worktree 已同步。

## 2026-09-13 B7a：公共日志增量对齐

本节不改写以上 2026-09-11 历史证据。模板固定 `tpl-backend@553c36b`，
Info 固定 `info-backend@f2c4001`；日志策略、Postgres 包装器、专项测试和说明逐字相同。
Worker 只同步信号注册，保留 crawl/distribution/search 领域任务；此差异属领域扩展。
无新增配置差异、临时兼容或违规漂移；没有以本次增量对齐重新宣称全仓对齐。

模板固定提交 88 passed 后串行同步 Info；Info 静态检查通过，固定提交全量
**301 passed / 0 skipped**（25.56 秒），真实一次性 PG/S3 与共享契约向量。
其中新增 8 项覆盖 API/Celery INFO/DEBUG、日志重初始化与告警保留。
无前端/迁移/契约变化；本轮没有 KIND、真实身份、发布回滚或业务数据验收。
关闭 SQL echo 和 SQL/HTTP INFO 不等于完整脱敏、指标或告警建设，部署仍待受控发布。
