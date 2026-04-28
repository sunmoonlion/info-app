# ============================================================================
# __APP_NAME__ Ingress YAML 生成配置
# ============================================================================

TEMPLATE_FILE="templates/ingress/ingress.yaml"
OUTPUT_FILE="__APP_NAME__-ingress-generated.yaml"
ENABLED="true"
RESOURCE_TYPE="ingress"

NAMESPACE="${NAMESPACE:-__NAMESPACE__}"
ENVIRONMENT="${ENVIRONMENT:-development}"
ENV="${ENV:-dev}"

# TODO: 填写 Ingress 路由配置
SERVICE_NAME="${SERVICE_NAME:-__APP_NAME__}"
SERVICE_PORT="${SERVICE_PORT:-__PORT__}"
UNIFIED_HOST="${UNIFIED_HOST:-TODO.sunmoonai.com}"
NODE_IP="${NODE_IP:-TODO_NODE_IP}"

USE_STRIP_PREFIX="${USE_STRIP_PREFIX:-false}"
USE_RATE_LIMIT="${USE_RATE_LIMIT:-false}"
