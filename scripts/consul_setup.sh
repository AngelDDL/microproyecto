#!/bin/bash

ROLE=$1
BIND_IP=$2

# --- Instalar Consul ---
echo "Instalando Consul..."
apt-get update -y
apt-get install -y unzip

CONSUL_VERSION="1.19.1"
curl -sSL https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip -o consul.zip
unzip consul.zip
mv consul /usr/local/bin/
rm consul.zip

# Crear usuario y directorios de Consul
useradd --system --home /etc/consul.d --shell /bin/false consul
mkdir -p /opt/consul
chown --recursive consul:consul /opt/consul

mkdir -p /etc/consul.d
chown --recursive consul:consul /etc/consul.d

# --- Configurar Systemd ---
cat <<EOF > /etc/systemd/system/consul.service
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/consul.d/consul.hcl

[Service]
User=consul
Group=consul
ExecStart=/usr/local/bin/consul agent -config-dir=/etc/consul.d/
ExecReload=/usr/local/bin/consul reload
KillMode=process
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF


# --- Configuracion especifica del ROL ---
if [ "$ROLE" == "server" ]; then
  echo "Configurando Consul como SERVIDOR..."
  cat <<EOF > /etc/consul.d/consul.hcl
  datacenter = "dc1"
  data_dir = "/opt/consul"
  server = true
  bootstrap_expect = 1
  ui_config {
    enabled = true
  }
  client_addr = "0.0.0.0"
  bind_addr = "192.168.56.10"
EOF

elif [ "$ROLE" == "client" ]; then
  echo "Configurando Consul como CLIENTE..."
  cat <<EOF > /etc/consul.d/consul.hcl
  datacenter = "dc1"
  data_dir = "/opt/consul"
  server = false
  bind_addr = "$BIND_IP"
  retry_join = ["192.168.56.10"]
EOF

  # Crear definicion del servicio webapp
  cat <<EOF > /etc/consul.d/webapp.json
  {
    "service": {
      "name": "webapp",
      "port": 3000,
      "check": {
        "http": "http://localhost:3000/health",
        "interval": "10s"
      }
    }
  }
EOF

fi

chown --recursive consul:consul /etc/consul.d

# Iniciar servicio
systemctl daemon-reload
systemctl enable consul.service
systemctl start consul.service

echo "Aprovisionamiento de Consul ($ROLE) completado!"