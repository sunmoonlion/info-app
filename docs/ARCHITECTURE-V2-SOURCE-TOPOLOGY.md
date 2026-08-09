# Info architecture-v2 source topology

- Status: active
- Updated: 2026-08-09

当前源码权威拓扑是 `admin-frontend + web-frontend + unified backend`。
`INSTANCE_FOUNDATION_ALIGNED.json`、P0-009 冻结标签以及旧 Web Backend 独立仓库
是迁移审计材料，不是当前部署声明。当前 v1 K8s 资源只在 R5/R7 切换完成前作为
运行基线/回滚面保留；不要从历史证据重新生成旧四组件源码。
