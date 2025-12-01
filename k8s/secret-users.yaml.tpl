apiVersion: v1
kind: Secret
metadata:
  name: clickhouse-users-secret
  namespace: clickhouse
  # Хранит пароли пользователей ClickHouse в виде Kubernetes Secret.
type: Opaque
stringData:
  # Пароль администратора, значение подставляется при генерации манифеста
  ${ADMIN_USER}_password: "${ADMIN_PASSWORD}"

  # Пароль пользователя с ограниченными правами
  ${READONLY_USER}_password: "${READONLY_PASSWORD}"
