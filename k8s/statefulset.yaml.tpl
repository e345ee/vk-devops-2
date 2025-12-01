apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: clickhouse
  namespace: clickhouse
spec:
  serviceName: clickhouse
  replicas: 1
  selector:
    matchLabels:
      app: clickhouse
  template:
    metadata:
      labels:
        app: clickhouse
    spec:
      containers:
        - name: clickhouse
          image: clickhouse/clickhouse-server:${CLICKHOUSE_VERSION}
          imagePullPolicy: IfNotPresent

          ports:
            - name: tcp
              containerPort: 9000
            - name: http
              containerPort: 8123

          # Liveness probe
          livenessProbe:
            httpGet:
              path: /ping
              port: http
            initialDelaySeconds: 30
            periodSeconds: 10
            timeoutSeconds: 3
            failureThreshold: 5

          # Readiness probe
          readinessProbe:
            tcpSocket:
              port: tcp
            initialDelaySeconds: 10
            periodSeconds: 5
            timeoutSeconds: 2
            failureThreshold: 3

          # Resource requests & limits
          resources:
            requests:
              cpu: "250m"
              memory: "512Mi"
            limits:
              cpu: "1"
              memory: "2Gi"

          volumeMounts:
            - name: data
              mountPath: /var/lib/clickhouse
            - name: users-config
              mountPath: /etc/clickhouse-server/users.d/custom-users.xml
              subPath: custom-users.xml

      volumes:
        - name: users-config
          configMap:
            name: clickhouse-users-config

  volumeClaimTemplates:
    - metadata:
        name: data
      spec:
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 5Gi