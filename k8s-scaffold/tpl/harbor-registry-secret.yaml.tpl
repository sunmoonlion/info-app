apiVersion: v1
kind: Secret
metadata:
  name: harbor-registry-secret
  namespace: ${NAMESPACE:-__NAMESPACE__}
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: ${HARBOR_DOCKER_CONFIG_JSON}
