apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: __APP_NAME__-pvc
  namespace: ${NAMESPACE:-__NAMESPACE__}
  labels:
    app: __APP_NAME__
spec:
  accessModes:
    - ${PVC_ACCESS_MODE:-ReadWriteOnce}
  storageClassName: ${PVC_STORAGE_CLASS:-}
  resources:
    requests:
      storage: ${PVC_STORAGE_SIZE:-10Gi}
