apiVersion: v1
kind: ConfigMap
metadata:
  name: __APP_NAME__-config
  namespace: ${NAMESPACE}
  labels:
    app: __APP_NAME__
data:
  # TODO: 添加 ConfigMap key 列表（非敏感配置）
  # 格式：KEY: "${KEY}"
  # 示例：
  #   NODE_ENV: "${NODE_ENV}"
  #   PORT: "${PORT}"
  #   REDIS_HOST: "${REDIS_HOST}"
  #   CASDOOR_ENDPOINT: "${CASDOOR_ENDPOINT}"
