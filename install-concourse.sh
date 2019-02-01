#!/bin/bash
# Concourse install script for ubuntu 16.04
# - Installs Postgres
# - Runs concourse internally on 8080
# - Creates a *valid* 90 day SSL cert via Letsencrypt certbot
# - Includes cron.d job for auto SSL renewal!!
# - Runs HTTPD as a reverse proxy: 80->8080, 443->8080
# - Handles websocket for fly hijack
# - Redirects 80 to 443

set -e -u

CONCOURSE_VERSION=3.14.1

sudo apt update

# Install packages
sudo apt -y install postgresql postgresql-contrib traceroute

# Configure Postgres
sudo -u postgres createuser concourse
sudo -u postgres createdb --owner=concourse atc

# Configure Concourse
sudo mkdir -p /etc/concourse

sudo wget -q -O /usr/local/bin/concourse https://github.com/concourse/concourse/releases/download/v$CONCOURSE_VERSION/concourse_linux_amd64

sudo chmod +x /usr/local/bin/concourse

sudo ssh-keygen -t rsa -q -N '' -f /etc/concourse/tsa_host_key
sudo ssh-keygen -t rsa -q -N '' -f /etc/concourse/worker_key
sudo ssh-keygen -t rsa -q -N '' -f /etc/concourse/session_signing_key

sudo cp /etc/concourse/worker_key.pub /etc/concourse/authorized_worker_keys

sudo bash -c 'cat > /etc/concourse/web_environment' <<EOF
CONCOURSE_SESSION_SIGNING_KEY=/etc/concourse/session_signing_key
CONCOURSE_TSA_HOST_KEY=/etc/concourse/tsa_host_key
CONCOURSE_TSA_AUTHORIZED_KEYS=/etc/concourse/authorized_worker_keys
CONCOURSE_POSTGRES_SOCKET=/var/run/postgresql

CONCOURSE_BASIC_AUTH_USERNAME=admin
CONCOURSE_BASIC_AUTH_PASSWORD=admin
CONCOURSE_EXTERNAL_URL=http://127.0.0.1:8080
EOF

sudo bash -c 'cat > /etc/concourse/worker_environment' <<EOF
CONCOURSE_WORK_DIR=/var/lib/concourse
CONCOURSE_TSA_WORKER_PRIVATE_KEY=/etc/concourse/worker_key
CONCOURSE_TSA_PUBLIC_KEY=/etc/concourse/tsa_host_key.pub
CONCOURSE_TSA_HOST=127.0.0.1:2222
EOF

sudo adduser --system --group concourse

sudo chown -R concourse:concourse /etc/concourse
sudo chmod 600 /etc/concourse/*_environment

sudo bash -c 'cat >/etc/systemd/system/concourse-web.service' <<EOF
[Unit]
Description=Concourse CI web process (ATC and TSA)
After=postgresql.service

[Service]
User=concourse
Restart=on-failure
EnvironmentFile=/etc/concourse/web_environment
ExecStart=/usr/local/bin/concourse web

[Install]
WantedBy=multi-user.target
EOF

sudo bash -c 'cat >/etc/systemd/system/concourse-worker.service' <<EOF
[Unit]
Description=Concourse CI worker process
After=concourse-web.service

[Service]
User=root
Restart=on-failure
EnvironmentFile=/etc/concourse/worker_environment
ExecStart=/usr/local/bin/concourse worker

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl start concourse-web concourse-worker
sudo systemctl enable concourse-web concourse-worker
