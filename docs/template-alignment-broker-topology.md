# B7t：预建 broker 拓扑增量对齐

2026-09-13，Luna 单人实施、自测。本报告独立保存本包证据，不改或提交此前已存在的
`template-alignment-durable-delivery.md` 工作区增量。

模板真源 `tpl-backend@44e74fe02d29616dfe636b06cc717bd9698536d9`；本仓固定候选
`info-backend@5fb909b6a012bfa62d1002abb6deb3fd9e3dc016`。
共用门禁 `tpl-app@fb9aee86646b51fad16cc17bd3e81be919eb5591` 先在模板通过外层 33 项、
内层 Backend 258 项零跳过，再串行推进本仓。

| 分类 | 本包处置 |
| --- | --- |
| 公共增量 | worker.py/config.py 同步预建开关、禁止未知队列、确认与 mandatory；公共测试/说明逐字相同 |
| 领域扩展 | 保留 Info 抓取/分发/搜索任务注册、领域配置与服务；不修改迁移或 provider 锁 |
| 配置差异 | 默认队列等原领域值保留；新增开关默认 false，与模板相同；不改变部署注入 |
| 暂时兼容 | 无新增；原默认自动声明模式按模板保留 |
| 违规漂移 | 本四文件增量未发现；不外推全仓所有文件相同 |

最终固定提交 Ruff 全量、Pyright、3 项新增配置测试通过；共用外层门禁 **33 passed /
0 skipped（124.14 秒）**，其中 30 项真实 broker 权限/缺失拓扑/进程验收，另有 1 项
完整回归包装、2 项辅助服务验收。内层完整 Backend **503 passed / 0 skipped
（81.91 秒）**，含真实一次性 PG/S3、原故障回归与共享交互向量/领域契约测试。

完整回归使用独立宽权限测试 vhost，不充作窄权限角色证据；没有证明 DB/broker 独立
凭据联合业务启动、领域任务真实 broker 迟确认/恢复或 KIND 发布回滚已通过。
临时 RabbitMQ、PG、MinIO、Valkey 及自身匿名卷清理并验证不存在，不动业务容器/数据。

公共新增文件 SHA-256：

```text
app/tests/test_broker_topology.py 7351cae7dd12faf52a3d9e8710d3fd084d6ccfd47e75f9b33fdc78a7eec376f9
docs/broker-topology.md 3b1aace826a3b48fe9e75f3699a1fdbdc835e40a54243a084f36cd5acc654d48
```

未构建/部署新镜像、未改 Secret/definitions/业务数据库，父仓 gitlink 暂不更新。
未合并 master 或推送远端；按所有者决定，剩余处置完成后再统一集成同步。
