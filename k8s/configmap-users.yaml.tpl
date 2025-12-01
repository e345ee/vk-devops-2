apiVersion: v1
kind: ConfigMap
metadata:
  name: clickhouse-users-config
  namespace: clickhouse
  # Дополнительная конфигурация пользователей ClickHouse
data:
  # Файл будет смонтирован в каталог users.d
  custom-users.xml: |
    <clickhouse>
      <users>
        # Администратор. Параметры подставляются через envsubst
        <${ADMIN_USER}>
          <password>${ADMIN_PASSWORD}</password>
          <profile>default</profile>
          <quota>default</quota>
          <networks>
            <ip>::/0</ip>
          </networks>
        </${ADMIN_USER}>

      # Пользователь с правами только на чтение
        <${READONLY_USER}>
          <password>${READONLY_PASSWORD}</password>
          <profile>readonly</profile>
          <quota>default</quota>
          <networks>
            <ip>::/0</ip>
          </networks>
        </${READONLY_USER}>
      </users>
    </clickhouse>
