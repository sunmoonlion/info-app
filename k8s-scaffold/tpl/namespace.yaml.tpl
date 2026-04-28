apiVersion: v1
kind: Namespace
metadata:
  name: ${NAMESPACE}
  labels:
    app: app-platform
    component: __APP_NAME__
    environment: ${ENVIRONMENT}
    managed-by: deploy-script
