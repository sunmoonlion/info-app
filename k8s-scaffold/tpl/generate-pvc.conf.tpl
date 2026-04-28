# ============================================================================
# __APP_NAME__ PVC YAML 生成配置
# ============================================================================

TEMPLATE_FILE="templates/pvc/__APP_NAME__-pvc.yaml"
OUTPUT_FILE="__APP_NAME__-pvc-generated.yaml"
ENABLED="true"
RESOURCE_TYPE="pvc"

NAMESPACE="${NAMESPACE:-__NAMESPACE__}"
ENVIRONMENT="${ENVIRONMENT:-development}"
ENV="${ENV:-dev}"

PVC_NAME="${PVC_NAME:-__APP_NAME__-pvc}"
PVC_STORAGE_CLASS="${PVC_STORAGE_CLASS:-local-path}"
PVC_ACCESS_MODE="${PVC_ACCESS_MODE:-ReadWriteOnce}"
PVC_STORAGE_SIZE="${PVC_STORAGE_SIZE:-10Gi}"
