#!/bin/bash

# --- Instalar HAProxy y Consul Template ---
echo "Instalando HAProxy y Consul Template..."
apt-get update -y
apt-get install -y haproxy unzip

# Crear carpeta para paginas de error y copiar la nuestra
mkdir -p /etc/haproxy/errors
cp /vagrant_configs/503.html /etc/haproxy/errors/503.html

CT_VERSION="0.32.0"
curl -sSL https://releases.hashicorp.com/consul-template/${CT_VERSION}/consul-template_${CT_VERSION}_linux_amd64.zip -o ct.zip
unzip ct.zip
mv consul-template /usr/local/bin/
rm ct.zip

# --- Configurar Consul Template ---
echo "Configurando Consul Template..."
mkdir -p /etc/consul-template.d

# Copiar la plantilla de HAProxy
cp /vagrant_configs/haproxy.cfg.tpl /etc/consul-template.d/haproxy.cfg.tpl

# Crear el archivo de configuracion de Consul Template
cat <<EOF > /etc/consul-template.d/config.hcl
consul {
  address = "192.168.56.10:8500"
}

template {
  source      = "/etc/consul-template.d/haproxy.cfg.tpl"
  destination = "/etc/haproxy/haproxy.cfg"
  command     = "systemctl reload haproxy"
}
EOF

# --- Crear y configurar el servicio de Consul Template ---
echo "Creando el servicio systemd para Consul Template..."
cat <<EOF > /etc/systemd/system/consul-template.service
[Unit]
Description=Consul Template
Requires=network-online.target
After=network-online.target

[Service]
User=root
Group=root
ExecStart=/usr/local/bin/consul-template -config=/etc/consul-template.d/config.hcl
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Habilitar e iniciar servicios
systemctl daemon-reload
systemctl enable consul-template.service
systemctl start consul-template.service
systemctl enable haproxy
systemctl start haproxy

echo "Aprovisionamiento del Balanceador de Carga completado!"