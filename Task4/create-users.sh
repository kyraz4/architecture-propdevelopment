#!/bin/sh

set -eu

# Создание пользователей Kubernetes через client certificates.
# В production сертификаты должны выпускаться и храниться
# через корпоративный PKI/CA или внешний механизм управления
# идентификацией.

CERT_DIR="${CERT_DIR:-./certs}"
mkdir -p "$CERT_DIR"

K8S_CA_KEY="${K8S_CA_KEY:-/var/lib/minikube/certs/ca.key}"
K8S_CA_CERT="${K8S_CA_CERT:-/var/lib/minikube/certs/ca.crt}"

if [ ! -f "$K8S_CA_KEY" ] || [ ! -f "$K8S_CA_CERT" ]; then
    echo "ERROR: Kubernetes CA files not found."
    echo "Start Minikube first or set K8S_CA_KEY and K8S_CA_CERT."
    exit 1
fi

create_user() {
    USERNAME="$1"
    GROUP="$2"

    echo "Creating certificate for ${USERNAME} (${GROUP})..."

    openssl genrsa -out "${CERT_DIR}/${USERNAME}.key" 2048

    openssl req \
        -new \
        -key "${CERT_DIR}/${USERNAME}.key" \
        -out "${CERT_DIR}/${USERNAME}.csr" \
        -subj "/CN=${USERNAME}/O=${GROUP}"

    openssl x509 \
        -req \
        -in "${CERT_DIR}/${USERNAME}.csr" \
        -CA "$K8S_CA_CERT" \
        -CAkey "$K8S_CA_KEY" \
        -CAcreateserial \
        -out "${CERT_DIR}/${USERNAME}.crt" \
        -days 365 \
        -sha256

    kubectl config set-credentials "$USERNAME" \
        --client-certificate="${CERT_DIR}/${USERNAME}.crt" \
        --client-key="${CERT_DIR}/${USERNAME}.key" \
        --embed-certs=true

    echo "User ${USERNAME} created."
}

# Пользователь только для просмотра.
create_user "analyst-user" "analysts"

# Пользователь-разработчик.
create_user "developer-user" "developers"

# Пользователь платформенной команды.
create_user "platform-user" "platform-admins"

# Пользователь службы безопасности.
create_user "security-user" "security-team"

# Пользователь администратора RBAC.
create_user "rbac-admin-user" "security-admins"

echo
echo "Users created successfully."
echo "Certificates are stored in: ${CERT_DIR}"
