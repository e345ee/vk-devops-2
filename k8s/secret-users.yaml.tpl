apiVersion: v1
kind: Secret
metadata:
  name: clickhouse-users-secret
  namespace: clickhouse
type: Opaque
stringData:
  ${ADMIN_USER}_password: "${ADMIN_PASSWORD}"
  ${READONLY_USER}_password: "${READONLY_PASSWORD}"
