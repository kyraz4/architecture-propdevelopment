#!/bin/sh

set -eu

# ============================================================
# ClusterRoleBinding: analysts -> cluster-readonly
# ============================================================

kubectl create clusterrolebinding analysts-readonly \
    --clusterrole=cluster-readonly \
    --group=analysts \
    --dry-run=client -o yaml | kubectl apply -f -

# ============================================================
# ClusterRoleBinding: developers -> cluster-readonly
# ============================================================

kubectl create clusterrolebinding developers-readonly \
    --clusterrole=cluster-readonly \
    --group=developers \
    --dry-run=client -o yaml | kubectl apply -f -

# ============================================================
# RoleBinding: developers -> namespace-operator
# ============================================================

kubectl create rolebinding developers-operator \
    --role=namespace-operator \
    --group=developers \
    --namespace=default \
    --dry-run=client -o yaml | kubectl apply -f -

# ============================================================
# ClusterRoleBinding: platform-admins -> cluster-operator
# ============================================================

kubectl create clusterrolebinding platform-admins-operator \
    --clusterrole=cluster-operator \
    --group=platform-admins \
    --dry-run=client -o yaml | kubectl apply -f -

# ============================================================
# ClusterRoleBinding: security-team -> security-admin
# ============================================================

kubectl create clusterrolebinding security-team-admin \
    --clusterrole=security-admin \
    --group=security-team \
    --dry-run=client -o yaml | kubectl apply -f -

# ============================================================
# ClusterRoleBinding: security-admins -> rbac-admin
# ============================================================

kubectl create clusterrolebinding security-admins-rbac \
    --clusterrole=rbac-admin \
    --group=security-admins \
    --dry-run=client -o yaml | kubectl apply -f -

# ============================================================
# Проверка созданных привязок
# ============================================================

echo
echo "RBAC bindings:"
kubectl get clusterrolebindings
echo
echo "Default namespace role bindings:"
kubectl get rolebindings -n default

echo
echo "RBAC configuration completed successfully."
