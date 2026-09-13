# Info 模板对齐：可靠投递开发候选

## 2026-09-13 暂停集成

所有者改为暂停并同步现有成果，本次父仓固定后端 `5fb909b6a012bfa62d1002abb6deb3fd9e3dc016`。
后续 B7u 固定完整回归 503 passed / 0 skipped；累计证据与未完项见 k8s
`sunmoonai/docs/v5-backlog-disposition-luna.md` 和 `v5-backlog-joint-runtime-identity-luna.md`。
下文“本地/尚未推送”保留为各包当时历史；源码同步不是正式镜像发布或业务身份切换。

## 2026-09-13 B7j 回执进展（本地，未发布）

最终固定检查点 `info-backend@7dafb34ca70d1f71ebc332315bf0c7584b9c3092`，模板
`a91eb3e284ae91d4bc6b82fe567c4163cfa728f0` 修订后 255 项先过，本仓再完整
**500 passed / 0 skipped，83.31 秒**，Ruff/Pyright 通过。修订只将 gauge 下降用例
改为移除隔离合成回执，不假定域 Outbox 可直接删除；归档只读保护和正式逻辑不动。
以下保留首轮候选历史；最终门禁以本段为准。

模板 `tpl-backend@a37835132217d8458a7440532f07d437a4684e3b` 固定全量 255 项先通过，
Info `info-backend@8baeefc432ca653bb670cf1fca9cbe4256c376a9` 完整
**500 passed / 0 skipped，83.74 秒**，Ruff/Pyright 通过。
共享观测器增加精确已提交 Inbox 数量/最大记录时间，保留 gauge 和无回执策略；
非有限回执使采集失败。两文件增量及四个新测试文件同步，不新增业务表或身份。
差异分类：原抓取/分发 handler、consumer 和租约领域扩展保留；无配置新增差异、
临时兼容或公共增量违规漂移，不声明全仓相同。
真实 prefork 暂停/父进程 pong/恢复、重复消费和回滚通过；测试替换的只是隔离存储及
合成 handler，既有真实 PG/S3 和契约套件仍执行。回执不是业务成功量、per-worker
健康或真实 Provider/部署验收，监控接线仍未来 N4-OPS-01。
六文件固定证据见 k8s `sunmoonai/docs/v5-backlog-worker-progress-luna.md`；
父仓 gitlink 不暂存、master 不改、不推送，等待最终统一集成。

## 2026-09-13 B7i 本地增量（尚未发布）

模板固定 `tpl-backend@ed157e41f11e5e20e6b77812890cb55d382b58f4` 全量 243 项通过后，
Info 同步为 `info-backend@0a6675d679e59ead6153386e898aed3c1dc0825e`；固定提交
Ruff/Pyright 通过，完整 **488 passed / 0 skipped，74.92 秒**。
五个新增 Scheduler 活动/CLI/测试/说明文件逐字同步，bootstrap 仅加观察类选择。
差异分类：Info 领域任务、handler 与调度清单保留；配置无新增差异，使用原 schedule
路径；无临时兼容层或公共增量违规漂移。此为六文件增量，不宣称全仓相同。

真实本仓 Beat 向合成队列发布、暂停/恢复/重启活动探针及既有真实 PG/S3/契约均通过。
循环返回、发送调用返回/异常分别记录，不当 Worker 业务完成或实际 KIND 探针验收；
无镜像/部署/迁移/身份修改。监控安装/采集/告警送达由未来 N4-OPS-01 接收，未实施。
本地提交与证据见 k8s `sunmoonai/docs/v5-backlog-scheduler-activity-luna.md`；
父仓 gitlink 不暂存、不推送，master 和云端留待最终统一集成。

## 2026-09-13 B7h 本地增量（尚未发布）

模板 `c66654a591b186ac814cadb907defc421e94aba6` → Info
`da870e0f1fa243d5b06e4de7b28a5c7d86a85c46`，严格等模板全量通过后实施。
新增服务身份保护的 `GET /api/internal/v1/delivery/metrics`，需要 `delivery:observe`；
复用只读 collector/已有 API 池，每进程单个在途采集，失败不输出假零或旧快照。
公共 endpoint、24 项 HTTP 测试、观测说明三文件与模板 SHA-256 完全一致；路由/响应头
仅加同一增量，不改 Info handler、采集/分发、Provider 或领域路由。旧“Internal 无
router”的休眠声明随能力激活改为正向检查，与指南同步；不是绕过门禁。

差异分类：领域扩展保留；Info 身份/audience 配置保留且不默认授予 scope；无新增暂时
兼容层；本包公共三文件无违规漂移。前端、迁移、部署与依赖未变。首轮 Ruff/Pyright
通过，完整回归 444 passed / 0 skipped（59.94 秒），固定提交复验回执见 k8s
`sunmoonai/docs/v5-backlog-metrics-http-luna.md`。本节不替代历史全量比较。
父仓 gitlink、master、远端及云端仍不更新，等待本轮剩余处置完成后一次性集成。

复验新增失败已处置：旧 readiness 测试的 50 ms 注入泄漏到正常恢复阶段，模板用
100 ms 合成正常延迟稳定复现后修复上下文范围；另统一观测 statement-timeout 的
恢复预算。Info 最终本地检查点 `a9f0d7b262e00b39b163c69dbaf39d2966679478`，
固定提交 Ruff/Pyright 通过，445 passed / 0 skipped（61.77 秒）；正式超时未改。
两个修正测试与模板完全一致，本节上面的 444 项是失败发现前的首轮历史，不是最终状态。

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
  以上为当时记录；2026-09-13 B7g 已实际复现首探针 DNS 解析失败，修复 DNS 前置门禁、
  拒绝判定和诊断/清理安全，并在第二个全新 Calico 集群通过当前 Info 策略的六条流向。
  证据见 k8s 的 v5-backlog-network-gate-luna.md；不追认已丢失原始现场的具体 DNS RCODE。
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

## 2026-09-13 B7b：API schema readiness 增量对齐

模板固定 `tpl-backend@ed8d5dc` 的 107 项回归先通过；Info 固定
`info-backend@96e3762` 全量 **320 passed / 0 skipped**（30.08 秒），Ruff/Pyright 通过。
共 4 文件：schema_readiness、测试、说明逐字同步，API factory 只加入相同健康检查增量；
包名、路由及领域扩展保留。各 App 的期望 revision 由自身迁移链导出，不复制模板 revision。
没有新增配置/兼容项/违规漂移；新增 19 项，真实一次性 PG 迁移/降级再升级、仅 SELECT
角色、阻塞超时和恢复，加既有 S3/契约完整回归。本次是增量对齐，不重新宣称全仓相同。

API ready 只读校验精确 revision，三别名不改；依赖检查总计 2 秒协作式超时，live 不变。
无迁移文件/前端/契约/部署变更，业务 API principal 权限和 KIND/身份/发布回滚未重验。
Info 重复创建逻辑分发的独立缺口仍待后续修复，本包不以健康检查测试替代该项验收。

## 2026-09-13 B7d：只读投递观测增量对齐

模板固定 `tpl-backend@1f8941f` 的 131 项先通过；Info 固定 `info-backend@9ea1c5e`
全量 **375 passed / 0 skipped**（41.51 秒），Ruff/Pyright 通过。
5 个新文件与模板逐字相同：delivery_metrics CLI、delivery_observation 聚合器、
delivery_observers 扩展点、24 项专项测试及说明。实例三个 topic 来自原 handler 注册，
不另建配置列表；不修改领域实现、迁移、API、前端或契约。

领域扩展仍由既有 handler 提供；本增量无配置差异、临时兼容或违规漂移，不代表全仓重验。
JSON/Prometheus text 只读输出当前账本 gauge，真实 PG/S3 和契约回归通过；没有业务数据
访问、KIND/真实身份/部署回滚或 scrape/告警接线验收。B7c 逻辑去重保持通过，B7b 那条
“待修复”是历史时点；本包不以只读聚合结果证明 Worker/Scheduler 正常或授权归档删除。

## 2026-09-13 B7e：Worker 消费配置检查增量

模板固定 `tpl-backend@5369862` 全量 167 项先通过；Info 固定 `info-backend@7755da2`
全量 **411 passed / 0 skipped**（57.14 秒），Ruff/Pyright 通过。
消除 WSL 双重校时冲突后同提交再跑 **411 passed / 0 skipped**（54.77 秒）。
新增 worker_readiness CLI、35 项单元、1 项真实 RabbitMQ/本仓 prefork Worker 测试及说明，
四文件与模板逐字同步；另同步既有观测测试的局部 monkeypatch 故障作用域修正，生产预算不改。
测试验证 pong 仍通但无/错队列时拒绝就绪、恢复通过、错节点/停止/断连失败、超时及安全输出。

领域扩展保留，所需任务直接来自本仓 `app.tasks.*`；无额外配置、临时兼容或违规漂移。
此为增量对齐，不代表全仓代码相同或 KIND/真实身份/发布回滚已重验。
本包不修改业务数据、API、迁移、前端、跨仓 DTO 或旧 release/bundle；实例探针须在下次
联合新镜像发布时接线，不能对旧镜像单独换命令。消费进展/Scheduler/采集/告警仍单列。


## 2026-09-13 B7f：显式投递状态与时钟回退

模板本地固定 `tpl-backend@1c5173b` 先过 176 项完整门禁，再串行 Info→Knowledge→Investment。
本仓本地固定 `info-backend@fbb48ef` 全量 **421 passed / 0 skipped**，Ruff/Pyright 通过。
公共四生产文件、9 项故障回归及说明六文件与模板 SHA-256 一致。
新增一项调用原抓取取消场景的故障回归；领域来源锁和 handler 未改。
没有新增配置差异、临时兼容或违规漂移；这是增量对齐，不重新声称全仓相同。

释放使用负无穷而不删除 epoch 行，立即入队/重放/对账不添加墙钟门槛；真正预约与退避保留。
原失败断言未改，先在旧代码确定性复现再验证修复；详细记录在 k8s 的
v5-backlog-clock-regression-luna.md。没有改系统校时、迁移/前端/契约/Secret/镜像或业务部署。
本轮按所有者要求只保存本地 Luna 候选，父仓 gitlink 暂未更新，未合并 master 或推送同步；
待剩余处置完成后统一集成。真实身份/KIND/发布回滚与运行监控不因本次通过而自动销账。
