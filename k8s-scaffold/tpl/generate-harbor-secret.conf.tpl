# ============================================================================
# Harbor Registry Secret YAML 生成配置
# ============================================================================

TEMPLATE_FILE="templates/secret/harbor-registry-secret.yaml"
OUTPUT_FILE="harbor-registry-secret-generated.yaml"
ENABLED="true"
RESOURCE_TYPE="secret"

NAMESPACE="${NAMESPACE:-__NAMESPACE__}"
ENVIRONMENT="${ENVIRONMENT:-development}"
ENV="${ENV:-dev}"

# TODO: 填写 Harbor 仓库凭据
DOCKER_SERVER="${DOCKER_SERVER:-__REGISTRY__}"
DOCKER_USERNAME="${DOCKER_USERNAME:-admin}"
DOCKER_PASSWORD="${DOCKER_PASSWORD:-TODO_FILL_IN_HARBOR_PASSWORD}"
