# ============================================================================
# __APP_NAME__ 部署配置
# 职责：部署控制参数，数据内容在 generate-*.conf 中
# ============================================================================

# TODO: 填写 PROJECT_ID 和 NAMESPACE
__APP_NAME_UPPER___PROJECT_ID="${__APP_NAME_UPPER___PROJECT_ID:-sunmoonai}"
__APP_NAME_UPPER___NAMESPACE="${__APP_NAME_UPPER___NAMESPACE:-__NAMESPACE__}"
ENVIRONMENT="${ENVIRONMENT:-development}"   # production|development

# Harbor 地址不要写死为 harbor.sunmoonai.com:30443。
# 部署入口只传 kind/c1，由 k8s/utils/cluster-config-mapping.sh 统一解析。
__APP_NAME_UPPER___IMAGE_REGISTRY="${__APP_NAME_UPPER___IMAGE_REGISTRY:-__REGISTRY__}"
KIND___APP_NAME_UPPER___IMAGE_REGISTRY="__KIND_REGISTRY__"
DOCKER_SERVER="${DOCKER_SERVER:-__REGISTRY__}"
KIND_DOCKER_SERVER="__KIND_REGISTRY__"

# 组件开关（控制是否部署）
namespace_enabled="true"
secrets_enabled="true"
configmap_enabled="true"
middleware_enabled="false"
ingress_enabled="true"

# 部署优先级（数值越大越先部署）
namespace_priority=3000
secrets_priority=2000
configmap_priority=1900
middleware_priority=1000
ingress_priority=100
