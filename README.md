# ClickHouse Kubernetes Deployment

Проект тестовое для vk devops intern.
Данный проект разворачивает одиночный экземпляр ClickHouse в Kubernetes с параметризуемой конфигурацией.  
Шаблоны YAML-манифестов генерируются через `envsubst`, управление ресурсами выполняется с помощью `Makefile`, а проверка развёртывания реализована в GitHub Actions.

## Возможности

- StatefulSet с одним экземпляром ClickHouse
- Параметризация версии образа и учетных данных пользователей
- ConfigMap с пользовательской конфигурацией ClickHouse (users.xml)
- Secret для хранения паролей пользователей
- Liveness и Readiness probes
- Resource requests и limits
- PersistentVolumeClaim для хранения данных
- Makefile для генерации, применения и удаления манифестов
- Автоматическая проверка развертывания через GitHub Actions

## Структура проекта

```
clickhouse-k8s/
├── k8s/
│   ├── namespace.yaml
│   ├── service.yaml
│   ├── statefulset.yaml.tpl
│   ├── configmap-users.yaml.tpl
│   ├── secret-users.yaml.tpl
│   └── generated/        # итоговые манифесты создаются автоматически
├── values.yaml           # документированное описание параметров
├── Makefile              # автоматизация генерации и деплоя
└── .github/workflows/
    └── clickhouse-ci.yml
```

## Параметризация

По умолчанию значения определены в `Makefile`:

```makefile
CLICKHOUSE_VERSION ?= 24.8
ADMIN_USER        ?= admin
ADMIN_PASSWORD    ?= admin_password
READONLY_USER     ?= readonly
READONLY_PASSWORD ?= readonly_password
```

Их можно переопределить при запуске:

```
CLICKHOUSE_VERSION=25.1 ADMIN_PASSWORD=secret make apply
```

Файл `values.yaml` предоставляет документированный набор тех же параметров.

## Локальный запуск

Необходимо наличие:

- Kubernetes-кластера (kind, minikube или другой)
- kubectl
- make
- envsubst (в составе gettext-base)

Развёртывание:

```
make apply
```

Проверка состояния:

```
make status
```

Тестирование подключения:

```
make test
```

Удаление ресурсов:

```
make delete
```

## CI/CD

GitHub Actions выполняет полный цикл проверки:

1. Создаёт kind-кластер.
2. Генерирует манифесты через `make generate`.
3. Разворачивает ClickHouse (`make apply`).
4. Ожидает готовности StatefulSet.
5. Выполняет запрос `SELECT 1` через clickhouse-client (`make test`).
6. Удаляет ресурсы (`make delete`).

Workflow расположен в `.github/workflows/clickhouse-ci.yml`.

## Назначение проекта

Решение демонстрирует базовые навыки DevOps:

- использование Kubernetes как среды развёртывания,
- параметризацию конфигурации,
- автоматизацию работы с манифестами,
- работу с Secret и ConfigMap,
- настройку probes и ресурсов,
- использование CI для проверки работоспособности.
