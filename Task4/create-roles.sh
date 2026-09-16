#!/bin/sh

set -eu

kubectl apply -f - <<'EOF'

# ============================================================
# 1. Только чтение ресурсов кластера
# ============================================================

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-readonly
rules:
  - apiGroups: [""]
    resources:
      - pods
      - services
      - configmaps
      - namespaces
      - nodes
      - events
    verbs: ["get", "list", "watch"]

  - apiGroups: ["apps"]
    resources:
      - deployments
      - replicasets
      - statefulsets
      - daemonsets
    verbs: ["get", "list", "watch"]

  - apiGroups: ["batch"]
    resources:
      - jobs
      - cronjobs
    verbs: ["get", "list", "watch"]

  - apiGroups: ["networking.k8s.io"]
    resources:
      - ingresses
      - networkpolicies
    verbs: ["get", "list", "watch"]

---
# ============================================================
# 2. Управление бизнес-сервисами
# ============================================================

apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: namespace-operator
  namespace: default
rules:
  - apiGroups: [""]
    resources:
      - pods
      - services
      - configmaps
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]

  - apiGroups: ["apps"]
    resources:
      - deployments
      - replicasets
      - statefulsets
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]

  - apiGroups: ["batch"]
    resources:
      - jobs
      - cronjobs
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]

  - apiGroups: ["networking.k8s.io"]
    resources:
      - ingresses
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]

---
# ============================================================
# 3. Администратор кластера
# ============================================================

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-operator
rules:
  - apiGroups: [""]
    resources:
      - pods
      - services
      - configmaps
      - namespaces
      - nodes
      - persistentvolumes
      - resourcequotas
      - limitranges
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]

  - apiGroups: ["apps"]
    resources:
      - deployments
      - replicasets
      - statefulsets
      - daemonsets
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]

  - apiGroups: ["batch"]
    resources:
      - jobs
      - cronjobs
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]

  - apiGroups: ["networking.k8s.io"]
    resources:
      - ingresses
      - networkpolicies
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]

---
# ============================================================
# 4. Служба безопасности — просмотр Secrets и RBAC
# ============================================================

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: security-admin
rules:
  - apiGroups: [""]
    resources:
      - secrets
      - serviceaccounts
    verbs: ["get", "list", "watch"]

  - apiGroups: ["rbac.authorization.k8s.io"]
    resources:
      - roles
      - rolebindings
      - clusterroles
      - clusterrolebindings
    verbs: ["get", "list", "watch"]

  - apiGroups: [""]
    resources:
      - pods
      - services
      - namespaces
      - events
    verbs: ["get", "list", "watch"]

---
# ============================================================
# 5. Администратор RBAC
# ============================================================

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: rbac-admin
rules:
  - apiGroups: ["rbac.authorization.k8s.io"]
    resources:
      - roles
      - rolebindings
      - clusterroles
      - clusterrolebindings
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
EOF

echo "Kubernetes roles created successfully."
