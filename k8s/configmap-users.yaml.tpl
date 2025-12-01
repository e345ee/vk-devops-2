apiVersion: v1
kind: ConfigMap
metadata:
  name: clickhouse-users-config
  namespace: clickhouse
data:
  custom-users.xml: |
    <clickhouse>
      <users>
        <${ADMIN_USER}>
          <password>${ADMIN_PASSWORD}</password>
          <profile>default</profile>
          <quota>default</quota>
          <networks>
            <ip>::/0</ip>
          </networks>
        </${ADMIN_USER}>

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
