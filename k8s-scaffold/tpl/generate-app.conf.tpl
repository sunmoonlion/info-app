# ============================================================================
# __APP_NAME__ Deployment YAML 生成配置
# ============================================================================

TEMPLATE_FILE="templates/app/__APP_NAME__.yaml"
OUTPUT_FILE="__APP_NAME__-generated.yaml"
ENABLED="true"
RESOURCE_TYPE="app"

NAMESPACE="${NAMESPACE:-__NAMESPACE__}"
ENVIRONMENT="${ENVIRONMENT:-development}"
ENV="${ENV:-dev}"

# 镜像配置
__APP_NAME_UPPER___IMAGE_REGISTRY="${__APP_NAME_UPPER___IMAGE_REGISTRY:-__REGISTRY__}"
__APP_NAME_UPPER___IMAGE_PROJECT="${__APP_NAME_UPPER___IMAGE_PROJECT:-__IMAGE_PROJECT__}"
__APP_NAME_UPPER___IMAGE="${__APP_NAME_UPPER___IMAGE:-__APP_NAME__}"
__APP_NAME_UPPER___TAG="${__APP_NAME_UPPER___TAG:-1.0.0}"
IMAGE_PULL_POLICY="${IMAGE_PULL_POLICY:-Always}"
__APP_NAME_UPPER___IMAGE_PULL_SECRET_NAME="${__APP_NAME_UPPER___IMAGE_PULL_SECRET_NAME:-harbor-registry-secret}"

# Secret / ConfigMap 名称
__APP_NAME_UPPER___SECRET_NAME="${__APP_NAME_UPPER___SECRET_NAME:-__APP_NAME__-secret}"
__APP_NAME_UPPER___CONFIGMAP_NAME="${__APP_NAME_UPPER___CONFIGMAP_NAME:-__APP_NAME__-config}"

# PVC 配置
PVC_NAME="${PVC_NAME:-__APP_NAME__-pvc}"
PVC_MOUNT_PATH="${PVC_MOUNT_PATH:-/app/data}"
PVC_SUB_PATH="${PVC_SUB_PATH:-}"
