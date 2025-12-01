apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: clickhouse
  namespace: clickhouse
  # StatefulSet разворачивает ClickHouse как состояние-зависимый сервис.
  # Обеспечивает стабильное имя пода и постоянный диск.
spec:
  serviceName: clickhouse
  replicas: 1 # Один экземпляр для упрощённого тестового окружения
  selector:
    matchLabels:
      app: clickhouse
  template:
    metadata:
      labels:
        app: clickhouse
        # Метка используется сервисом для маршрутизации трафика.
    spec:
      containers:
        - name: clickhouse
          image: clickhouse/clickhouse-server:${CLICKHOUSE_VERSION}
          # Версия образа параметризуется и подставляется при генерации манифеста.
          imagePullPolicy: IfNotPresent

          ports:
            - name: tcp
              containerPort: 9000 # нативный протокол ClickHouse
            - name: http
              containerPort: 8123 # HTTP API ClickHouse

          # Проверка работоспособности контейнера.
          livenessProbe:
            httpGet:
              path: /ping
              port: http
            initialDelaySeconds: 30
            periodSeconds: 10
            timeoutSeconds: 3
            failureThreshold: 5

          # Проверка готовности к обслуживанию запросов.
          readinessProbe:
            tcpSocket:
              port: tcp
            initialDelaySeconds: 10
            periodSeconds: 5
            timeoutSeconds: 2
            failureThreshold: 3

          # Ограничения и запросы ресурсов.
          resources:
            requests:
              cpu: "250m"
              memory: "512Mi"
            limits:
              cpu: "1"
              memory: "2Gi"

          volumeMounts:
            # Персистентные данные ClickHouse
            - name: data
              mountPath: /var/lib/clickhouse
            # Подключение users.xml из ConfigMap
            - name: users-config
              mountPath: /etc/clickhouse-server/users.d/custom-users.xml
              subPath: custom-users.xml

      volumes:
        # ConfigMap с конфигурацией пользователей
        - name: users-config
          configMap:
            name: clickhouse-users-config
# PVC создаётся автоматически для хранения данных ClickHouse.
  volumeClaimTemplates:
    - metadata:
        name: data
      spec:
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 5Gi